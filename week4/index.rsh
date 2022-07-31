'reach 0.1';
'use strict';

export const main = Reach.App(() => {
    const alice = Participant('Alice', {
        deadline: UInt,
        timeExpiration: Fun([], Null),
    });
    const eve = Participant('Eve', {
        getCallLog: Fun([], Bytes(256)),
    });

    init();

    alice.only(() => {
        const deadline = declassify(interact.deadline);
    });
    alice.publish(deadline);
    commit();

    eve.only(() => {
        const callLog = declassify(interact.getCallLog());
    });
    eve.publish(callLog)
        .timeout(relativeTime(deadline), () => closeTo(alice, alice.interact.timeExpiration));
    commit();
});
