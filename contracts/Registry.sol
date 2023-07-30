// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/utils/Create2Upgradeable.sol";
import "./interfaces/IERC6551Registry.sol";
import "./Access.sol";

contract Registry is Access, IERC6551Registry {
    error InitializationFailed();

    mapping(address => bool) public allowedTokenContracts;
    mapping(address => bytes32) public allowedImplmentations;

    function initialize() external initializer {
        __Access_init();
    }

    function updateAllowedNFT(address _nft, bool _enabled) external onlyAdmin {
        allowedTokenContracts[_nft] = _enabled;
        emit UpdateAllowedNFT(_nft, _enabled);
    }

    function updateImplementation(
        address _implementation,
        bytes32 _salt
    ) external onlyAdmin {
        allowedImplmentations[_implementation] = _salt;
        emit UpdateImplementation(_implementation, _salt);
    }

    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt,
        bytes calldata initData
    ) external override returns (address) {
        require(
            allowedTokenContracts[tokenContract],
            "Registry: token contract not allowed"
        );

        require(
            allowedImplmentations[implementation] != bytes32(0),
            "Registry: implementation not allowed"
        );

        bytes memory code = _creationCode(
            implementation,
            chainId,
            tokenContract,
            tokenId,
            salt
        );

        address _account = Create2Upgradeable.computeAddress(
            bytes32(salt),
            keccak256(code)
        );

        if (_account.code.length != 0) return _account;

        _account = Create2Upgradeable.deploy(0, bytes32(salt), code);

        if (initData.length != 0) {
            (bool success, ) = _account.call(initData);
            if (!success) revert InitializationFailed();
        }

        emit AccountCreated(
            _account,
            implementation,
            chainId,
            tokenContract,
            tokenId,
            salt
        );

        return _account;
    }

    function account(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    ) external view override returns (address) {
        bytes32 bytecodeHash = keccak256(
            _creationCode(implementation, chainId, tokenContract, tokenId, salt)
        );

        return Create2Upgradeable.computeAddress(bytes32(salt), bytecodeHash);
    }

    function _creationCode(
        address implementation_,
        uint256 chainId_,
        address tokenContract_,
        uint256 tokenId_,
        uint256 salt_
    ) internal view returns (bytes memory) {
        return
            abi.encodePacked(
                "Empire-Of-CHARM",
                implementation_,
                allowedImplmentations[implementation_],
                abi.encode(salt_, chainId_, tokenContract_, tokenId_)
            );
    }

    event UpdateAllowedNFT(address indexed nft, bool enabled);
    event UpdateImplementation(address indexed implementation, bytes32 enabled);
}
