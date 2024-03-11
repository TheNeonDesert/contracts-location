//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

interface IResourceToken {
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
    function mintBatch(
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
    function addResources(string[] calldata names) external;
}
