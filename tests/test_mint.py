import pytest

from brownie import ConcertTickets, accounts, Factory
import brownie

name = "TestExample"
symbol = "TEX"
location = "Berkeley"
numTier = 5
URI = "TESTURI"
protocolFee = 50
tierPrice = [1, 10, 100, 1000, 10000]
tierMaxSupply = [10, 10, 10, 10, 10]
tierSupply = [0, 0, 0, 0, 0]
tierURI = ["a", "b", "c", "d", "e"]
eventTime = 100000


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


def create_collection(factory, owner, artist, market):
    factory.setMarket(market, {"from": owner})
    collection = factory.createCollection(
        name,
        eventTime,
        location,
        symbol,
        protocolFee,
        URI,
        numTier,
        tierMaxSupply,
        tierPrice,
        tierURI,
        {"from": artist},
    )

    collection = ConcertTickets.at(collection.return_value)
    return collection


def test_metadata(factory, owner, artist, market):
    concert_tickets = create_collection(factory, owner, artist, market)
    assert concert_tickets.symbol() == symbol
    assert concert_tickets.name() == name
    assert concert_tickets.numTier() == numTier
    assert concert_tickets.protocolFee() == protocolFee
    for i in range(numTier):
        assert concert_tickets.tierMaxSupply(i) == tierMaxSupply[i]
        assert concert_tickets.tierSupply(i) == tierSupply[i]
        assert concert_tickets.tierPrice(i) == tierPrice[i]


def test_mint_basic(factory, owner, artist, market):
    concert_tickets = create_collection(factory, owner, artist, market)
    # Pass
    for i in range(numTier):
        concert_tickets.mint(i, market, {"value": tierPrice[i], "from": market})
        assert concert_tickets.balanceOf(market) == i + 1

    # Fail Fund
    for i in range(numTier):
        with brownie.reverts("TICKET: Not Enough Funds"):
            concert_tickets.mint(i, market, {"value": tierPrice[i] - 1, "from": market})


def test_mint_max_supply(factory, owner, artist, market):
    concert_tickets = create_collection(factory, owner, artist, market)
    # Pass
    totalTix = 0
    for i in range(numTier):
        for j in range(tierMaxSupply[i]):
            concert_tickets.mint(i, market, {"value": tierPrice[i], "from": market})
            totalTix += 1
            assert concert_tickets.balanceOf(market) == totalTix
        with brownie.reverts("TICKET: Sold Out"):
            concert_tickets.mint(i, market, {"value": tierPrice[i], "from": market})
