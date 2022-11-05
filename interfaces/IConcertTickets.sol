pragma solidity ^0.8.0;

interface IConcertTickets {
    event Log(string message, uint256 data);

    function setRoyalty(uint96 royalty_) external;

    function unlock() external;

    function withdraw(address to_) external;

    function mint(uint8 tier_, address to_) external payable;

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function artist() external view returns (address);

    function location() external view returns (string memory);

    function eventTime() external view returns (uint256);

    function factory() external view returns (address);

    function market() external view returns (address);

    function protocolFee() external view returns (uint8);

    function numTier() external view returns (uint256);

    function tierSupply(uint8 tier_) external view returns (uint256);

    function tierMaxSupply(uint8 tier_) external view returns (uint256);

    function tierPrice(uint8 tier_) external view returns (uint256);

    function locked() external view returns (bool);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function approve(address to, uint256 tokenId) external;
}
