pragma solidity ^0.8.0;

import "./ConcertTickets.sol";

contract Factory {
    address private _owner;
    address private _market;
    address[] private _ticketCollections;
    uint256 _totalEvents;

    modifier onlyOwner() {
        require(msg.sender == _owner, "FACTORY: Not Owner");
        _;
    }

    constructor(address owner_) {
        _owner = owner_;
    }

    function createCollection(
        string memory name_,
        uint256 eventTime_,
        string memory location_,
        string memory symbol_,
        uint8 protocolFee_,
        string memory URI_,
        uint8 numTier_,
        uint256[] memory tierMaxSupply_,
        uint256[] memory tierPrice_,
        string[] memory tierURI_
    ) external returns (address) {
        ConcertTickets collection = new ConcertTickets(
            name_,
            eventTime_,
            location_,
            symbol_,
            protocolFee_,
            URI_,
            numTier_,
            tierMaxSupply_,
            tierPrice_,
            tierURI_
        );
        // Save mapping artist -> Collection
        _ticketCollections.push(address(collection));
        _totalEvents += 1;

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

    function ticketCollections() public view returns (address[] memory) {
        return _ticketCollections;
    }

    function totalEvents() public view returns (uint256) {
        return _totalEvents;
    }
}
