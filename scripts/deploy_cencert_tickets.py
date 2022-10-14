from brownie import accounts, config, ConcertTickets, EasyToken
from scripts.helpful_scripts import get_account


def main():
    account = get_account()
    tix = ConcertTickets.deploy(
        "supercool",
        "spk",
        50,
        5,
        [100, 100, 100, 100, 100],
        [0, 10, 100, 1000, 10000],
        {"from": account},
    )
    print(tix.factory({"from": account}), account)
    print(tix.artist({"from": account}), account)

    tx = tix.mint(0, account, {"from": account})
    print(tx.events)
    tx = tix.mint(0, account, {"from": account})
    print(tx.events)
