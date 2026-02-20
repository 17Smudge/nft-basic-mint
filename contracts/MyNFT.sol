// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NftCollection is ERC721, Ownable, Pausable {
    using Strings for uint256;

    uint256 public immutable maxSupply;
    uint256 private _totalSupply;
    string private _baseTokenURI;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_,
        string memory baseURI_
    ) ERC721(name_, symbol_) Ownable(msg.sender) {
        require(maxSupply_ > 0, "maxSupply=0");
        maxSupply = maxSupply_;
        _baseTokenURI = baseURI_;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        _requireOwned(tokenId);

        return string(
            abi.encodePacked(
                _baseTokenURI,
                tokenId.toString(),
                ".json"
            )
        );
    }



    function mint(address to, uint256 tokenId)
        external
        onlyOwner
        whenNotPaused
    {
        require(to != address(0), "zero address");
        require(tokenId > 0 && tokenId <= maxSupply, "id out of range");
        require(_totalSupply < maxSupply, "max supply reached");

        _mint(to, tokenId);

        unchecked {
            _totalSupply++;
        }
    }


    function burn(uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(_isAuthorized(owner, msg.sender, tokenId), "not authorized");

        _burn(tokenId);

        unchecked {
            _totalSupply--;
        }
    }



    function setBaseURI(string calldata newBaseURI)
        external
        onlyOwner
    {
        _baseTokenURI = newBaseURI;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }



    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        require(!paused(), "paused");
        return super._update(to, tokenId, auth);
    }
}