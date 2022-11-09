from brownie import Factory, ConcertTickets, accounts, Contract, Market
import brownie


def main():
    acc = accounts.load("deployer")

    # factory = Factory.at("0x1007A9eD753652d179e87ED158a6BbfD73F102f3")
    # acc = accounts[0]
    # print(factory.ticketCollections({"from": acc}))
    collection = ConcertTickets.at("0x2c17d1Dc7B86BCE8e8f1A72dec9dD3969c17F253")
    print(collection.name())
    print(collection.symbol())
    print(collection.eventTime())
    print(collection.location())
    print(collection.protocolFee())
    print(collection.URI())
    print(collection.numTier())
    for i in range(2):
        print(collection.tierMaxSupply(i))
        print(collection.tierPrice(i))
        print(collection.tierURI(i))
