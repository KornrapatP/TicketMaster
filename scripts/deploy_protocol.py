from brownie import Factory, ConcertTickets, accounts, Contract, Market
import brownie


def main():
    deployer = accounts.load("deployer")
    factory = Factory.deploy(deployer, {"from": deployer})
    market = Market.deploy(deployer, {"from": deployer})
    factory.setMarket(market, {"from": deployer})
    market.setFactory(factory, {"from": deployer})
