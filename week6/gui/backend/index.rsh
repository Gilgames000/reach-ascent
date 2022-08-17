'reach 0.1';
'use strict';

export const main = Reach.App(() => {
    const fortuneTeller = Participant('FortuneTeller', {
        price: UInt,
        readFortune: Fun([], Bytes(256)),
        reportAcceptance: Fun([], Null),
        reportRejection: Fun([], Null)
    });
    const customer = Participant('Customer', {
        requestFortune: Fun([], Null),
        acceptFortune: Fun([Bytes(256)], Bool)
    });

    init();

    fortuneTeller.only(() => {
        const price = declassify(interact.price);
    });
    fortuneTeller.publish(price);
    commit();

    customer.pay(price);
    customer.interact.requestFortune();

    var hasCustomerAccepted = false;
    invariant(balance() == price);
    while (!hasCustomerAccepted) {
        commit();

        fortuneTeller.only(() => {
            const fortune = declassify(interact.readFortune());
        });
        fortuneTeller.publish(fortune);
        commit();

        customer.only(() => {
            const accepted = declassify(interact.acceptFortune(fortune));
        });
        customer.publish(accepted);
        if (!accepted) {
            fortuneTeller.interact.reportRejection();
        }
        hasCustomerAccepted = accepted;
        continue;
    }

    fortuneTeller.interact.reportAcceptance();
    transfer(balance()).to(fortuneTeller);
    commit();
});
