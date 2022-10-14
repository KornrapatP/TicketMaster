pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../interfaces/IFactory.sol";

contract ConcertTickets is ERC721 {
    address private _artist;
    address private _factory;
    uint256[] private _tierSupply;
    uint256[] private _tierMaxSupply;
    uint256[] private _tierPrice;
    uint8 _numTier;
    uint8 _protocolFee; // Percentage

    event Log(string message, uint256 data);

    modifier onlyArtist() {
        require(msg.sender == _artist, "TICKET: Not Artist");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == _factory, "TICKET: Not Factory");
        _;
    }

    modifier onlyMarket() {
        require(msg.sender == _factory, "TICKET: Not Market");
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 protocolFee_,
        uint8 numTier_,
        uint256[] memory tierMaxSupply_,
        uint256[] memory tierPrice_
    ) ERC721(name_, symbol_) {
        _artist = tx.origin;
        _factory = msg.sender;
        _protocolFee = protocolFee_;
        _numTier = numTier_;
        for (uint256 i = 0; i < numTier_; i++) {
            _tierMaxSupply.push(tierMaxSupply_[i]);
            _tierPrice.push(tierPrice_[i]);
            _tierSupply.push(0);
        }
    }

    function withdraw(address to_) external onlyArtist {
        uint256 amount_ = address(this).balance;
        uint256 toProtocol_ = (_protocolFee * amount_) / 100; // safemath?
        payable(_factory).transfer(toProtocol_);
        payable(to_).transfer(amount_ - toProtocol_);
    }

    function mint(uint8 tier_, address to_) public payable onlyMarket {
        require(tier_ < _numTier, "TICKET: Tier Invalid");

        // Check amount ETH
        require(msg.value >= _tierPrice[tier_], "TICKET: Not Enough Funds");

        // Check Mintable
        require(_tierSupply[tier_] < _tierMaxSupply[tier_], "TICKET: Sold Out");
        uint256 id_ = 0;
        for (uint256 i = 0; i < tier_; i++) {
            id_ += _tierMaxSupply[i]; // Change to safemath?
        }
        id_ += _tierSupply[tier_]; // Change to safemath?

        // Refund Extra
        uint256 change = msg.value - _tierPrice[tier_];
        payable(tx.origin).transfer(change);

        // Mints
        _safeMint(to_, id_);

        // update variables
        _tierSupply[tier_] += 1;
    }

    function artist() public view returns (address) {
        return _artist;
    }

    function factory() public view returns (address) {
        return _factory;
    }

    function market() public view returns (address) {
        return IFactory(_factory).market();
    }

    function protocolFee() public view returns (uint8) {
        return _protocolFee;
    }

    function numTier() public view returns (uint256) {
        return _numTier;
    }

    function tierSupply(uint8 tier_) public view returns (uint256) {
        require(tier_ < _numTier, "TICKET: Nonexistent");
        return _tierSupply[tier_];
    }

    function tierMaxSupply(uint8 tier_) public view returns (uint256) {
        require(tier_ < _numTier, "TICKET: Nonexistent");
        return _tierMaxSupply[tier_];
    }

    function tierPrice(uint8 tier_) public view returns (uint256) {
        require(tier_ < _numTier, "TICKET: Nonexistent");
        return _tierPrice[tier_];
    }
}
