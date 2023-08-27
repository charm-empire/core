// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "./Access.sol";

contract CharmERC721 is ERC721Upgradeable, Access {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIds;

    string private __baseURI;

    event BaseURIUpdated(string value, address from);

    function initialize(
        string memory name_,
        string memory symbol_,
        string memory baseURI_
    ) external initializer {
        __Access_init();
        __ERC721_init(name_, symbol_);
        setBaseURI(baseURI_);
    }

    function setBaseURI(string memory baseURI_) public onlyAdmin {
        __baseURI = baseURI_;
        emit BaseURIUpdated(baseURI_, _msgSender());
    }

    function _mint(address _to) internal {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();

        _mint(_to, tokenId);
    }

    function mint(
        address[] memory _to,
        uint256[] memory _qty
    ) public onlyAdmin {
        require(_to.length == _qty.length, "CharmERC721: length mismatch");

        for (uint256 i = 0; i < _to.length; i++) {
            for (uint256 j = 0; j < _qty[i]; j++) {
                _mint(_to[i]);
            }
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return __baseURI;
    }
}
