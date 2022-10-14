pragma solidity ^0.8.0;

interface IConcertTickets {
    event Log(string message, uint256 data);

    function withdraw(address to_) external;

    function mint(uint8 tier_, address to_) external payable;

    function artist() external view returns (address);

    function factory() external view returns (address);

    function market() external view returns (address);

    function protocolFee() external view returns (uint8);

    function numTier() external view returns (uint256);

    function tierSupply(uint8 tier_) external view returns (uint256);

    function tierMaxSupply(uint8 tier_) external view returns (uint256);

    function tierPrice(uint8 tier_) external view returns (uint256);
}
