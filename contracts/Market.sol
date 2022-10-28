pragma solidity ^0.8.0;

import "./ConcertTickets.sol";

contract Market {
    address private _factory;
    address private _owner;

    mapping(address => mapping(uint256 => uint256)) private _listing;

    mapping(address => mapping(uint256 => bool)) private _isListed;

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
        address payable collection_,
        uint8 tier_,
        address to_
    ) public payable {
        ConcertTickets(collection_).mint{value: msg.value}(tier_, to_);
    }

    function secondaryBuy(
        address payable collection_,
        uint256 id_,
        address to_
    ) public payable {
        require(_isListed[collection_][id_], "MARKET: Item not listed");
        (address artist_, uint256 artistFee_) = ConcertTickets(collection_)
            .royaltyInfo(id_, _listing[collection_][id_]);
        require(
            _listing[collection_][id_] + artistFee_ <= msg.value,
            "MARKET: Insufficient fund"
        );
        _isListed[collection_][id_] = false;
        address seller_ = ConcertTickets(collection_).ownerOf(id_);
        ConcertTickets(collection_).transferFrom(seller_, to_, id_);
        uint256 change = msg.value - (_listing[collection_][id_] + artistFee_);
        payable(msg.sender).transfer(change);
        payable(artist_).transfer(artistFee_);
        payable(seller_).transfer(_listing[collection_][id_]);
    }

    function secondaryList(
        address payable collection_,
        uint256 id_,
        uint256 price_
    ) public {
        require(
            msg.sender == ConcertTickets(collection_).ownerOf(id_),
            "MARKET: Not Your Ticket"
        );
        _isListed[collection_][id_] = true;
        _listing[collection_][id_] = price_;
    }

    function secondaryDelist(address payable collection_, uint256 id_) public {
        require(
            msg.sender == ConcertTickets(collection_).ownerOf(id_),
            "MARKET: Not Your Ticket"
        );
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

    function isListed(address payable collection_, uint256 id_)
        public
        view
        returns (bool)
    {
        return _isListed[collection_][id_];
    }

    function listing(address payable collection_, uint256 id_)
        public
        view
        returns (uint256, uint256)
    {
        (address artist_, uint256 artistFee_) = ConcertTickets(collection_)
            .royaltyInfo(id_, _listing[collection_][id_]);
        return (_listing[collection_][id_], artistFee_);
    }
}
