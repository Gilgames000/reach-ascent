'reach 0.1';
'use strict';

export const main = Reach.App(() => {
    const alice = Participant('Alice', {
        requestFortune: Fun([], Null),
        acceptFortune: Fun([Bytes(256)], Bool)
    });
    const bob = Participant('Bob', {
        price: UInt,
        readFortune: Fun([], Bytes(256)),
        reportAcceptance: Fun([], Null),
        reportRejection: Fun([], Null)
    });

    init();

    bob.only(() => {
        const price = declassify(interact.price);
    });
    bob.publish(price);
    commit();

    alice.pay(price);
    alice.interact.requestFortune();

    var hasAliceAccepted = false;
    invariant(balance() == price);
    while (!hasAliceAccepted) {
        commit();

        bob.only(() => {
            const fortune = declassify(interact.readFortune());
        });
        bob.publish(fortune);
        commit();

        alice.only(() => {
            const accepted = declassify(interact.acceptFortune(fortune));
        });
        alice.publish(accepted);
        if (!accepted) {
            bob.interact.reportRejection();
        }
        hasAliceAccepted = accepted;
        continue;
    }

    bob.interact.reportAcceptance();
    transfer(balance()).to(bob);
    commit();
});
