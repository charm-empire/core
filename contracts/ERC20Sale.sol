// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./interfaces/ICharmERC20.sol";
import "./Access.sol";

contract ERC20Sale is Access, ReentrancyGuardUpgradeable {
    uint256 public salePrice;
    ICharmERC20 public _token;

    function initialize(
        uint256 _price,
        ICharmERC20 __token
    ) external initializer {
        __Access_init();
        __ReentrancyGuard_init();

        if (_price == 0) {
            _price = 0.01 ether;
        }

        setSalePrice(_price);

        _token = __token;
    }

    function setSalePrice(uint256 _price) public onlyAdmin {
        salePrice = _price;

        emit SetSalePrice(_price, _msgSender());
    }

    function buy(uint256 _qty) external payable nonReentrant {
        require(
            msg.value == ((salePrice * _qty) / 1 ether),
            "ERC20Sale: invalid price"
        );

        _token.mint(_msgSender(), _qty);
    }

    event SetSalePrice(uint256 price, address from);
}
