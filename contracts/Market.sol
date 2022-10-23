pragma solidity ^0.8.0;

import "./ConcertTickets.sol";

contract Market {
    address private _factory;
    address private _owner;

    mapping(address => mapping(uint256 => uint256)) _listing;

    mapping(address => mapping(uint256 => bool)) _isListed;

    modifier onlyOwner() {
        require(msg.sender == _owner, "MARKET: Not Owner");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == _factory, "MARKET: Not Factory");
        _;
    }

    constructor(address owner_) {
        _owner = owner_;
    }

    function primaryBuy(
        address collection_,
        uint8 tier_,
        address to_
    ) public payble {
        ConcertTickets(collection_){value: msg.value}.mint(tier_, to_);
    }

    function secondaryBuy(
        address collection_,
        uint256 id_,
        address to_
    ) public payble {
        require(_isListed[collection_][tier_], "MARKET: Item not listed");
        uint256 artistFee_ = (_listing[collection_][tier_] *
            ConcertTickets(collection_).secondarySaleFee()) / 1000;
        require(
            _listing[collection_][tier_] + artistFee_ <= msg.value,
            "MARKET: Insufficient fund"
        );
        _isListed[collection_][tier_] = false;
        address seller_ = ConcertTickets(collection_).ownerOf(id_);
        ConcertTickets(collection_).transferFrom(seller_, to_, id_);
        uint256 change = msg.value -
            (_listing[collection_][tier_] + artistFee_);
        payable(msg.sender).transfer(change);
        payable(collection_).transfer(artistFee_);
        payable(seller).transfer(_listing[collection_][tier_]);
    }

    function secondaryList(
        address collection_,
        uint246 id_,
        uint256 price_
    ) public payble {
        _isListed[collection_][id_] = true;
        _listing[collection_][id_] = price_;
    }

    function secondaryDelist(address collection_, uint246 id_) public payble {
        _isListed[collection_][id_] = false;
    }

    function setFactory(address factory_) external onlyOwner {
        _factory = factory_;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function factory() public view returns (address) {
        return _factory;
    }
}
