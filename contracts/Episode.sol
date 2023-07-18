// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Podcast.sol";

contract Episode is ERC721URIStorage {
  using Counters for Counters.Counter;

  // Counter for _tokenIDs
  Counters.Counter private _tokenIDs;

  // Maps Owner address to Episode tokenID
  mapping(address => uint256[]) private _ownerToEpisodes;
  // Maps Episode tokenIDs to Podcast tokenID
  mapping(uint256 => uint256[]) private _podcastToEpisodes;
  // Maps Episode tokenID to Owner address
  mapping(uint256 => address) private _episodeToOwner;

  address podcastAddress;


  event episodeCreated(
    uint256 indexed podcastTokenID,
    uint256 indexed episodeTokenID,
    string episodeTokenURI,
    address sender
  );

  constructor(address _parent_address) ERC721("Episode", "EPISODE") {
      podcastAddress = _parent_address;
  }

  modifier onlyPodcast {
    require(msg.sender == podcastAddress);
    _;
  }

  function create(address _from, uint256 podcastTokenID, string memory uriBase) external onlyPodcast returns (uint256) {
    _tokenIDs.increment();

    // Next tokenID to use for minting
    uint256 tokenID = _tokenIDs.current();

    // Mint the NFT
    _mint(_from, tokenID);

    // Associate Episode tokenID to Owner address
    _ownerToEpisodes[_from].push(tokenID);
    // Associate Episode tokenID to Podcast tokenID
    _podcastToEpisodes[podcastTokenID].push(tokenID);
    // Associate Owner address to Episode tokenID
    _episodeToOwner[tokenID] = _from;

    string memory episodeTokenURI = string(abi.encodePacked(uriBase, "/episodes/", Strings.toString(tokenID), "/metadata.json"));

    _setTokenURI(tokenID, episodeTokenURI);

    emit episodeCreated(
      podcastTokenID,
      tokenID,
      episodeTokenURI,
      msg.sender
    );

    return tokenID;
  }

  /**
  * @dev Get all Episode `tokenIDs` owned by `_from` and associated with `podcastTokenID`
  *
  * Requirements:
  * - `podcastTokenID` must exist and also be owned by `_from`
  */
  function getByPodcast(uint256 podcastTokenID) external view onlyPodcast returns(uint256[] memory _owned) {
    return _podcastToEpisodes[podcastTokenID];
  }

  /**
  * @dev
  *
  * Requirements:
  * -
  */
  function getOwned(address _from) external view onlyPodcast returns(uint256[] memory _owned) {
    return _ownerToEpisodes[_from];
  }

  /**
   * @dev Returns boolean of whether `_from` owns Episode `tokenID`
   *
   * Requirements:
   * - `tokenID` must exist.
   * - `_from` must own `tokenID`.
   */
  function isOwned(address _from, uint256 tokenID) public view onlyPodcast  returns(bool) {
    _requireMinted(tokenID);

    require(_episodeToOwner[tokenID] == _from, "Invalid token owner");

    return true;
  }
}