pragma solidity ^0.8.0;

interface IFactory {
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
    ) external returns (address);

    function setMarket(address market_) external;

    function owner() external view returns (address);

    function market() external view returns (address);

    function ticketCollections() external view returns (address[] memory);

    function totalEvents() external view returns (uint256);
}
