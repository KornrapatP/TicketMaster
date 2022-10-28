import pytest

from brownie import Factory, ConcertTickets, accounts, Contract, Market
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
def fan1():
    return accounts[2]


@pytest.fixture
def fan2():
    return accounts[3]


@pytest.fixture
def protocol(owner, artist, fan1, fan2):
    factory = owner.deploy(Factory, owner)
    market = owner.deploy(Market, owner)
    factory.setMarket(market, {"from": owner})
    market.setFactory(factory, {"from": owner})
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

    collection = ConcertTickets.at(collection.return_value)
    null = accounts.at("0x0000000000000000000000000000000000000000", force=True)
    return factory, market, collection, artist, fan1, fan2, null


def test_set_factory_market(protocol):
    factory, market, collection, artist, fan1, fan2, null = protocol
    assert factory.market() == market
    assert market.factory() == factory

    # check factory collection data
    assert len(factory.ticketCollections()) == 1
    assert factory.ticketCollections()[0] == collection

    # Test 1 primary buy
    with brownie.reverts("TICKET: Not Enough Funds"):
        market.primaryBuy(collection, 1, fan1, {"from": fan1, "value": 9})
    market.primaryBuy(collection, 1, fan1, {"from": fan1, "value": 10})
    assert collection.balanceOf(fan1) == 1
    assert collection.ownerOf(10) == fan1
    with brownie.reverts("ERC721: invalid token ID"):
        collection.ownerOf(11)
    oldBal = fan1.balance()
    market.primaryBuy(collection, 1, fan1, {"from": fan1, "value": 20, "gas_price": 0})
    newBal = fan1.balance()
    assert collection.balanceOf(fan1) == 2
    assert collection.ownerOf(10) == fan1
    assert collection.ownerOf(11) == fan1
    assert oldBal - newBal == 10

    # Test secondary listing and delisting
    for i in range(5):
        with brownie.reverts():
            market.secondaryList(collection, 10, (15 + i) * 10, {"from": fan2})
        market.secondaryList(collection, 10, (15 + i) * 10, {"from": fan1})
        assert market.isListed(collection, 10) == True
        assert market.listing(collection, 10) == ((15 + i) * 10, (15 + i))
        # Try buying with insufficient funds
        with brownie.reverts("MARKET: Insufficient fund"):
            market.secondaryBuy(
                collection,
                10,
                fan2,
                {"from": fan2, "value": sum(market.listing(collection, 10)) - 1},
            )
        with brownie.reverts():
            market.secondaryDelist(collection, 10, {"from": fan2})
        market.secondaryDelist(collection, 10, {"from": fan1})
        assert market.isListed(collection, 10) == False

    # Test secondary buy
    market.secondaryList(collection, 10, 100000, {"from": fan1})
    oldBal = fan2.balance()
    with brownie.reverts():  # not approved yet
        market.secondaryBuy(
            collection,
            10,
            fan2,
            {"from": fan2, "value": 10000000, "gas_price": 0},
        )
    collection.approve(market, 10, {"from": fan1})
    market.secondaryBuy(
        collection,
        10,
        fan2,
        {"from": fan2, "value": 10000000, "gas_price": 0},
    )
    newBal = fan2.balance()
    assert oldBal - newBal == 100000 * 1.1
    assert collection.ownerOf(10) == fan2
    assert market.isListed(collection, 10) == False
    with brownie.reverts("MARKET: Item not listed"):
        market.secondaryBuy(
            collection,
            10,
            fan1,
            {"from": fan1, "value": 10000000, "gas_price": 0},
        )
