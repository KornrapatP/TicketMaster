import pytest

from brownie import Factory, ConcertTickets, accounts, Contract
import brownie

name = "TestExample"
symbol = "TEX"
numTier = 5
protocolFee = 50
tierPrice = [1, 10, 100, 1000, 10000]
tierMaxSupply = [10, 10, 10, 10, 10]
tierSupply = [0, 0, 0, 0, 0]
tierURI = ["a", "b", "c", "d", "e"]
eventTime = 1000000


@pytest.fixture
def owner():
    return accounts[0]


@pytest.fixture
def artist():
    return accounts[1]


@pytest.fixture
def market():  # dummy
    return accounts[2]


@pytest.fixture
def factory(owner, artist, market):
    return owner.deploy(Factory, owner)


def test_set_market(factory, owner, artist, market):
    factory.setMarket(market, {"from": owner})
    assert factory.market() == market
    with brownie.reverts("FACTORY: Not Owner"):
        factory.setMarket(artist, {"from": artist})
    assert factory.market() == market


def test_create_collection(factory, owner, artist, market):
    factory.setMarket(market, {"from": owner})
    collection = factory.createCollection(
        name,
        eventTime,
        symbol,
        protocolFee,
        numTier,
        tierMaxSupply,
        tierPrice,
        tierURI,
        {"from": artist},
    )
    # assert collection == ""

    collection = ConcertTickets.at(collection.return_value)
    assert collection.market() == market


# def test_metadata(concert_tickets):
#     assert concert_tickets.symbol() == symbol
#     assert concert_tickets.name() == name
#     assert concert_tickets.numTier() == numTier
#     assert concert_tickets.protocolFee() == protocolFee
#     for i in range(numTier):
#         assert concert_tickets.tierMaxSupply(i) == tierMaxSupply[i]
#         assert concert_tickets.tierSupply(i) == tierSupply[i]
#         assert concert_tickets.tierPrice(i) == tierPrice[i]


# def test_mint_basic(concert_tickets):
#     # Pass
#     for i in range(numTier):
#         concert_tickets.mint(
#             i, accounts[0], {"value": tierPrice[i], "from": accounts[0]}
#         )
#         assert concert_tickets.balanceOf(accounts[0]) == i + 1

#     # Fail Fund
#     for i in range(numTier):
#         with brownie.reverts("TICKET: Not Enough Funds"):
#             concert_tickets.mint(
#                 i, accounts[0], {"value": tierPrice[i] - 1, "from": accounts[0]}
#             )


# def test_mint_max_supply(concert_tickets):
#     # Pass
#     totalTix = 0
#     for i in range(numTier):
#         for j in range(tierMaxSupply[i]):
#             concert_tickets.mint(
#                 i, accounts[0], {"value": tierPrice[i], "from": accounts[0]}
#             )
#             totalTix += 1
#             assert concert_tickets.balanceOf(accounts[0]) == totalTix
#         with brownie.reverts("TICKET: Sold Out"):
#             concert_tickets.mint(
#                 i, accounts[0], {"value": tierPrice[i], "from": accounts[0]}
#             )
