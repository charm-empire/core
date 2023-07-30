// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract Access is OwnableUpgradeable {
    mapping(address => bool) public admins;

    event AdminUpdated(address indexed admin, bool value);

    modifier onlyAdmin() {
        require(
            admins[_msgSender()] || _msgSender() == owner(),
            "Access: only admin can call this function"
        );
        _;
    }

    /**
     * @dev Updates admin status
     * @param _admin address to update
     * @param _value whether admin or not
     */
    function updateAdmin(address _admin, bool _value) external onlyOwner {
        admins[_admin] = _value;
        emit AdminUpdated(_admin, _value);
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Access_init() public initializer {
        __Ownable_init();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
