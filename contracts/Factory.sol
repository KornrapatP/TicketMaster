pragma solidity ^0.8.0;

import "./ConcertTickets.sol";

contract Factory {
    address private _owner;
    address private _market;

    modifier onlyOwner() {
        require(msg.sender == _owner, "FACTORY: Not Owner");
        _;
    }

    constructor(address owner_) {
        _owner = owner_;
    }

    function createCollection(
        string memory name_,
        string memory symbol_,
        uint8 protocolFee_,
        uint8 numTier_,
        uint256[] memory tierMaxSupply_,
        uint256[] memory tierPrice_
    ) external returns (address) {
        ConcertTickets collection = new ConcertTickets(
            name_,
            symbol_,
            protocolFee_,
            numTier_,
            tierMaxSupply_,
            tierPrice_
        );
        // Save mapping artist -> Collection

        return address(collection);
    }

    function setMarket(address market_) external onlyOwner {
        _market = market_;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function market() public view returns (address) {
        return _market;
    }
}
