pragma solidity ^0.8.0;

interface IMarket {
    function primaryBuy(
        address collection_,
        uint8 tier_,
        address to_
    ) external payable;

    function secondaryBuy(
        address collection_,
        uint256 id_,
        address to_
    ) external payable;

    function secondaryList(
        address collection_,
        uint256 id_,
        uint256 price_
    ) external;

    function secondaryDelist(address collection_, uint256 id_) external;

    function setFactory(address factory_) external;

    function owner() external view returns (address);

    function factory() external view returns (address);

    function isListed(address collection_, uint256 id_)
        external
        view
        returns (bool);

    function listing(address collection_, uint256 id_)
        external
        view
        returns (uint256, uint256);
}
