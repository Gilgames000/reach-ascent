'reach 0.1';

export const main = Reach.App(() => {
    const commonInterface = {
        seePrice: Fun([], UInt),
        getDescription: Fun([], Bytes(1)),
    };

    const creator = Participant('Creator', commonInterface);
    const bidder = Participant('Bidder', commonInterface);
    const buyer = Participant('Buyer', commonInterface);

    init();

    bidder.only(() => {
        const price = declassify(interact.seePrice());
    });
    bidder.publish(price);
    commit();

    buyer.only(() => {
        const description = declassify(interact.getDescription());
    });
    buyer.publish(description).pay(price);
    transfer(price).to(buyer);
    commit();
});
