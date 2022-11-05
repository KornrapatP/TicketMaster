pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../interfaces/IFactory.sol";

contract ConcertTickets is ERC721URIStorage, ERC2981 {
    using Address for address;

    address private _artist;
    string private _location;
    uint256 private _eventTime;
    address private _factory;
    uint256[] private _tierSupply;
    uint256[] private _tierMaxSupply;
    uint256[] private _tierPrice;
    string[] private _tierURI;
    uint8 private _numTier;
    uint8 private _protocolFee; // Percentage
    bool private _locked;

    event Log(string message, uint256 data);
    event Received(address, uint256);

    modifier onlyArtist() {
        require(msg.sender == _artist, "TICKET: Not Artist");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == _factory, "TICKET: Not Factory");
        _;
    }

    modifier onlyMarket() {
        require(msg.sender == market(), "TICKET: Not Market");
        _;
    }

    constructor(
        string memory name_,
        uint256 eventTime_,
        string memory location_,
        string memory symbol_,
        uint8 protocolFee_,
        uint8 numTier_,
        uint256[] memory tierMaxSupply_,
        uint256[] memory tierPrice_,
        string[] memory tierURI_
    ) ERC721(name_, symbol_) {
        _artist = tx.origin;
        _eventTime = eventTime_;
        _factory = msg.sender;
        _protocolFee = protocolFee_;
        _numTier = numTier_;
        _locked = true;
        for (uint256 i = 0; i < numTier_; i++) {
            _tierMaxSupply.push(tierMaxSupply_[i]);
            _tierPrice.push(tierPrice_[i]);
            _tierSupply.push(0);
            _tierURI.push(tierURI_[i]);
        }
        _setDefaultRoyalty(address(this), 1000); // 10%
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function setRoyalty(uint96 royalty_) external onlyArtist {
        _setDefaultRoyalty(address(this), royalty_);
    }

    function unlock() external onlyArtist {
        _locked = false;
    }

    function withdraw(address to_) external onlyArtist {
        uint256 amount_ = address(this).balance;
        uint256 toProtocol_ = (_protocolFee * amount_) / 100; // safemath?
        payable(_factory).transfer(toProtocol_);
        payable(to_).transfer(amount_ - toProtocol_);
    }

    function mint(uint8 tier_, address to_) public payable onlyMarket {
        // Check to_ EOA
        if (_locked) {
            require(!to_.isContract(), "TICKET: Recipient is Contract");
        }

        // Check tier
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

        // Sets URI
        _setTokenURI(id_, _tierURI[tier_]);

        // update variables
        _tierSupply[tier_] += 1;
    }

    function artist() public view returns (address) {
        return _artist;
    }

    function location() public view returns (string memory) {
        return _location;
    }

    function eventTime() public view returns (uint256) {
        return _eventTime;
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

    function locked() public view returns (bool) {
        return _locked;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        if (_locked) {
            require(!to.isContract(), "TICKET: Recipient is Contract");
        }
        super._transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) public virtual override {
        // Only approve market
        if (_locked) {
            require(to == market(), "TICKET: Only approve market");
        }
        super.approve(to, tokenId);
    }
}
