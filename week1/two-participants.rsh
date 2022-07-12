'reach 0.1';
'use strict';

export const main = Reach.App(()=>{
    const commonInterface = {
        getChallenge: Fun([], UInt256),
        seeResult: Fun([UInt256], Null),
    };
    atob

    const pat = Participant('Pat', commonInterface);
    const vanna = Participant('Vanna', commonInterface);

    init();

    pat.only(() => {
        const challengePat = declassify(interact.getChallenge());
    });
    pat.publish(challengePat);
    commit();

    vanna.only(() => {
        const challengeVanna = declassify(interact.getChallenge());
    });
    vanna.publish(challengeVanna);
    commit();
});
