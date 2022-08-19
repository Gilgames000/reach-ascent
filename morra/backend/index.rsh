'reach 0.1';
'use strict';


const [isOutcome, HOST_WINS, DRAW, GUEST_WINS] = makeEnum(3);
const DEADLINE_BLOCKS = 30;

function normalizeFingers(fingers) {
    return fingers % 6;
}

function normalizeGuess(guess) {
    return guess % 11;
}

function calculateOutcome(hostFingers, hostGuess, guestFingers, guestGuess) {
    const normalizedHostGuess = normalizeGuess(hostGuess);
    const normalizedGuestGuess = normalizeGuess(guestGuess);
    const normalizedHostFingers = normalizeFingers(hostFingers);
    const normalizedGuestFingers = normalizeFingers(guestFingers);
    const winningNumber = normalizedHostFingers + normalizedGuestFingers;
    if (normalizedHostGuess == normalizedGuestGuess) {
        return DRAW;
    } else if (normalizedHostGuess == winningNumber) {
        return HOST_WINS;
    } else if (normalizedGuestGuess == winningNumber) {
        return GUEST_WINS;
    } else {
        return DRAW;
    }
}

forall(UInt, hostFingers =>
    forall(UInt, hostGuess =>
        forall(UInt, guestFingers =>
            forall(UInt, guestGuess =>
                assert(isOutcome(calculateOutcome(hostFingers, hostGuess, guestFingers, guestGuess)))))));

forall(UInt, (hostFingers) =>
    forall(UInt, (guestFingers) =>
        forall(UInt, (identicalGuess) =>
            assert(calculateOutcome(hostFingers, identicalGuess, guestFingers, identicalGuess) == DRAW))));


export const main = Reach.App(() => {
    const commonInterface = {
        ...hasRandom,
        getFingers: Fun([], UInt),
        getGuess: Fun([], UInt),
        reportOutcome: Fun([UInt], Null),
        reportTimeout: Fun([], Null),
    }
    const hostPlayer = Participant('HostPlayer', {
        wager: UInt,
        ...commonInterface,
    });
    const guestPlayer = Participant('GuestPlayer', {
        ...commonInterface,
    });

    init();

    const terminateGame = (payee) => {
        closeTo(payee, () => {
            each([hostPlayer, guestPlayer], () => interact.reportTimeout());
        });
    };

    hostPlayer.only(() => {
        const wager = declassify(interact.wager);
    });
    hostPlayer.publish(wager).pay(wager);
    commit();

    guestPlayer.pay(wager).timeout(relativeTime(DEADLINE_BLOCKS), () => terminateGame(hostPlayer));

    var outcome = DRAW;
    invariant(balance() == 2 * wager);
    invariant(isOutcome(outcome));
    while (outcome == DRAW) {
        commit();

        hostPlayer.only(() => {
            const _hostFingers = interact.getFingers();
            const [_hostFingersCommitment, _hostFingersSalt] = makeCommitment(interact, _hostFingers);
            const hostFingersCommitment = declassify(_hostFingersCommitment);

            const _hostGuess = interact.getGuess();
            const [_hostGuessCommitment, _hostGuessSalt] = makeCommitment(interact, _hostGuess);
            const hostGuessCommitment = declassify(_hostGuessCommitment);
        });
        hostPlayer.publish(hostFingersCommitment, hostGuessCommitment)
            .timeout(relativeTime(DEADLINE_BLOCKS), () => terminateGame(guestPlayer));
        commit();

        unknowable(guestPlayer, hostPlayer(_hostFingers, _hostFingersSalt, _hostGuess, _hostGuessSalt));

        guestPlayer.only(() => {
            const guestFingers = declassify(interact.getFingers());
            const guestGuess = declassify(interact.getGuess());
        });
        guestPlayer.publish(guestFingers, guestGuess)
            .timeout(relativeTime(DEADLINE_BLOCKS), () => terminateGame(hostPlayer));
        commit();

        hostPlayer.only(() => {
            const [hostFingers, hostFingersSalt] = declassify([_hostFingers, _hostFingersSalt]);
            const [hostGuess, hostGuessSalt] = declassify([_hostGuess, _hostGuessSalt]);

        });
        hostPlayer.publish(hostFingers, hostFingersSalt, hostGuess, hostGuessSalt)
            .timeout(relativeTime(DEADLINE_BLOCKS), () => terminateGame(guestPlayer));
        checkCommitment(hostFingersCommitment, hostFingersSalt, hostFingers);
        checkCommitment(hostGuessCommitment, hostGuessSalt, hostGuess);

        if (calculateOutcome(hostFingers, hostGuess, guestFingers, guestGuess) == DRAW) {
            hostPlayer.interact.reportOutcome(DRAW);
            guestPlayer.interact.reportOutcome(DRAW);
        }

        outcome = calculateOutcome(hostFingers, hostGuess, guestFingers, guestGuess);
        continue;
    }

    assert(outcome == HOST_WINS || outcome == GUEST_WINS);
    transfer(2 * wager).to(outcome == HOST_WINS ? hostPlayer : guestPlayer);
    commit();
    each([hostPlayer, guestPlayer], () => {
        interact.reportOutcome(outcome);
    })
});
