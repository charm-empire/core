// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "./Access.sol";

contract CharmERC20 is ERC20Upgradeable, Access {
    function initialize(
        string memory name_,
        string memory symbol_
    ) external initializer {
        __Access_init();
        __ERC20_init(name_, symbol_);
    }

    function mint(address _to, uint256 _qty) external onlyAdmin {
        _mint(_to, _qty);
    }

    function drop(
        address[] memory _to,
        uint256[] memory _qty
    ) external onlyAdmin {
        require(_to.length == _qty.length, "CharmERC20: length mismatch");

        for (uint256 i = 0; i < _to.length; i++) {
            _mint(_to[i], _qty[i]);
        }
    }
}
