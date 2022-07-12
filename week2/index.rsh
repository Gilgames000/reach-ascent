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
        const payment = declassify(interact.seePrice());
    });
    buyer.publish(description, payment).pay(payment);
    if(payment >= price){
        transfer(price).to(bidder);
        transfer(payment - price).to(buyer);
        // transfer bought goods to the buyer
    } else {
        transfer(payment).to(buyer);
    }
    commit();
});
