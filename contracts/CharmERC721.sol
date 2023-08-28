// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "./Access.sol";
import "./interfaces/ICharmERC20.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract CharmERC721 is ERC721Upgradeable, Access, ReentrancyGuardUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIds;

    string private __baseURI;

    event BaseURIUpdated(string value, address from);

    enum NFTType {
        DEFAULT
    }

    IERC20 public charmERC20;

    struct TokenMetadata {
        // last transferred at
        uint256 lastTransferredAt;
        // yeild is a recurring event
        uint256 yieldPerSecond;
        uint256 yieldTime;
        uint256 liqudatedYield;
        // activation is a one-time event
        bool activated;
        uint256 activatedAt;
        uint256 activationPrice;
    }

    mapping(uint256 => TokenMetadata) public tokenMetadata;

    function initialize(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        IERC20 _token
    ) external initializer {
        __Access_init();
        __ERC721_init(name_, symbol_);
        __ReentrancyGuard_init();

        setBaseURI(baseURI_);

        charmERC20 = _token;
    }

    function setBaseURI(string memory baseURI_) public onlyAdmin {
        __baseURI = baseURI_;
        emit BaseURIUpdated(baseURI_, _msgSender());
    }

    function __mint(address _to, NFTType _nftType) internal {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();

        super._mint(_to, tokenId);

        if (_nftType == NFTType.DEFAULT) {
            tokenMetadata[tokenId] = TokenMetadata({
                yieldPerSecond: (1 / 1000) * 1 ether,
                yieldTime: 24 * 3600 * 7,
                lastTransferredAt: block.timestamp,
                activationPrice: 60 ether,
                liqudatedYield: 0,
                activated: false,
                activatedAt: 0
            });
        }
    }

    function mint(
        address[] memory _to,
        uint256[] memory _qty
    ) public onlyAdmin {
        require(_to.length == _qty.length, "CharmERC721: length mismatch");

        for (uint256 i = 0; i < _to.length; i++) {
            for (uint256 j = 0; j < _qty[i]; j++) {
                __mint(_to[i], NFTType.DEFAULT);
            }
        }
    }

    function activateToken(uint256 tokenId) public nonReentrant {
        _requireMinted(tokenId);

        // owner can activate
        require(
            _msgSender() == ownerOf(tokenId),
            "CharmERC721: only owner can activate"
        );

        require(
            tokenMetadata[tokenId].activated == false,
            "CharmERC721: token already activated"
        );

        // transfer activation price
        charmERC20.transferFrom(
            _msgSender(),
            address(this),
            tokenMetadata[tokenId].activationPrice
        );
        tokenMetadata[tokenId].activated = true;

        // set activated at
        tokenMetadata[tokenId].activatedAt = block.timestamp;
        tokenMetadata[tokenId].lastTransferredAt = block.timestamp;
    }

    function liquifyYield(uint256 tokenId) public nonReentrant {
        _requireMinted(tokenId);

        // owner can liquify
        require(
            _msgSender() == ownerOf(tokenId),
            "CharmERC721: only owner can liquify"
        );

        // accumulated yield
        uint256 yield = accumulatedYield(tokenId);

        tokenMetadata[tokenId].liqudatedYield += yield;

        // transfer yield
        ICharmERC20(address(charmERC20)).mint(_msgSender(), yield);

        // update last transferred at
        tokenMetadata[tokenId].lastTransferredAt = block.timestamp;
    }

    // VIEW FUNCTIONS

    function accumulatedYield(uint256 tokenId) public view returns (uint256) {
        if (tokenMetadata[tokenId].activated == false) {
            return 0;
        }

        // time elapsed
        uint256 timeElapsed = block.timestamp -
            tokenMetadata[tokenId].lastTransferredAt;

        // yield per second
        uint256 yieldPerSecond = tokenMetadata[tokenId].yieldPerSecond;

        // yield time
        uint256 yieldTime = tokenMetadata[tokenId].yieldTime;

        // accumulated yield
        if (timeElapsed > yieldTime) {
            return
                (yieldPerSecond * yieldTime) -
                tokenMetadata[tokenId].liqudatedYield;
        } else {
            return
                (yieldPerSecond * timeElapsed) -
                tokenMetadata[tokenId].liqudatedYield;
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return __baseURI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        if (from != address(0) && to != address(0)) {
            for (uint256 i = 0; i < batchSize; i++) {
                uint256 tokenId = firstTokenId + i;

                // update last transferred at
                tokenMetadata[tokenId].lastTransferredAt = block.timestamp;
            }
        }
    }
}
