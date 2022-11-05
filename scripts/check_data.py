from brownie import Factory, ConcertTickets, accounts, Contract, Market
import brownie


def main():
    acc = accounts.load("deployer")

    # factory = Factory.at("0xe7eECE3919d8e8A43e8d6B569BBCe5Ef0224E2EF")
    # acc = accounts[0]
    # print(factory.ticketCollections({"from": acc}))
    collection = ConcertTickets.at("0xFd013CC373FFDc24b9A72A3368447304c55F5bd2")
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
