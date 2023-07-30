// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import "./interfaces/IERC6551Registry.sol";

contract ERC6551Registry is IERC6551Registry {
    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt,
        bytes calldata initData
    ) external override returns (address) {}

    function account(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    ) external view override returns (address) {}
}
