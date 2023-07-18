// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Episode.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Podcast is ERC721URIStorageUpgradeable, OwnableUpgradeable {
  using Counters for Counters.Counter;

  // Counter for tokenIDs
  Counters.Counter private _tokenIDs;

  // Maps Owner address to Podcast tokenID
  mapping(address => uint256[]) private _ownerPodcasts;
  // Maps Podcast tokenID to Episode tokenID
  mapping(uint256 => uint256[]) private _podcastEpisodes;
  // Maps Podcast tokenID to Owner address
  mapping(uint256 => address) private _tokenToOwner;
  // Maps Podcast tokenID to feedURI
  mapping(uint256 => string) private _feedURIs;

  Episode public episodeContract;


  event podcastCreated(
    uint256 indexed tokenID,
    string tokenURI,
    string feedURI,
    address sender
  );

  function initialize() public initializer {
    __ERC721_init("Podcast", "PODCAST");
    __Ownable_init();
    episodeContract = new Episode(address(this));
  }

  /**
   * @dev Creates a new Podcast NFT and returns tokenID
   *
   * Requirements:
   *
   * - `uriBase` must exist.
   */
  function create(string memory uriBase) onlyOwner public returns (uint256) {
    _tokenIDs.increment();

    // Next tokenID to use for minting
    uint256 tokenID = _tokenIDs.current();

    // Mint the NFT
    _mint(msg.sender, tokenID);

    // Associate tokenID to Owner
    _tokenToOwner[tokenID] = msg.sender;
    // Add tokenID to Owner's Podcast list
    _ownerPodcasts[msg.sender].push(tokenID);

    _setTokenURI(tokenID, string(abi.encodePacked(uriBase, Strings.toString(tokenID), "/metadata.json")));
    _setFeedURI(tokenID, string(abi.encodePacked(uriBase, Strings.toString(tokenID), "/feed.xml")));

    emit podcastCreated(
      tokenID,
      tokenURI(tokenID),
      feedURI(tokenID),
      msg.sender
    );

    return tokenID;
  }

  /**
   * @dev Creates a new Episode NFT associated with the Podcast `tokenID` and returns `episodeTokenID`
   *
   * Requirements:
   *
   * - `tokenID` must exist.
   * - `tokenID` must be owned by sender.
   */
  function createEpisode(uint256 tokenID, string memory uriBase) onlyOwner public returns (uint256) {
    _requireMinted(tokenID);
    _isOwned(msg.sender, tokenID);

    // Create Episode NFT
    uint256 episodeTokenID = episodeContract.create(msg.sender, tokenID, string(abi.encodePacked(uriBase, Strings.toString(tokenID))));

    // Add Episode to Podcast
    _podcastEpisodes[tokenID].push(episodeTokenID);

    return episodeTokenID;
  }

  /**
   * @dev Sets `_feedURI` as the feedURI of `tokenID`.
   *
   * Requirements:
   * - `tokenID` must exist.
   * - msg.sender must own `tokenID`
   * - `podcastFeed` must be sent
   *
   */
  function _setFeedURI(uint256 tokenID, string memory podcastFeed) internal virtual {
    _feedURIs[tokenID] = podcastFeed;
  }

  /**
   * @dev Returns the Feed Uniform Resource Identifier (URI) for `tokenID` token.
   *
   * Requirements:
   * - `tokenID` must exist.
   */
  function feedURI(uint256 tokenID) public view virtual returns (string memory) {
    _requireMinted(tokenID);

    return _feedURIs[tokenID];
  }

  /**
   * @dev Returns all owned `tokenID`s for the sender
   */
  function getOwned() public view returns(uint256[] memory _owned) {
    return _ownerPodcasts[msg.sender];
  }

  /**
   * @dev Returns boolean of whether the sender owns a particular `tokenID`
   */
  function isOwnedByTokenID(uint256 tokenID) public view returns(bool) {
    return _isOwned(msg.sender, tokenID);
  }

  /**
   * @dev Returns all episodes associated with podcast `tokenID`
   *
   * Requirements:
   * - `tokenID` must exist.
   */
  function getEpisodes(uint256 tokenID) public view returns(uint256[] memory episodes) {
    _requireMinted(tokenID);

    return episodeContract.getByPodcast(tokenID);
  }

  /**
   * @dev Returns all episodes associated with sender
   *
   */
  function getOwnedEpisodes() public view returns(uint256[] memory episodes) {
    return episodeContract.getOwned(msg.sender);
  }

  /**
   * @dev Returns specific episode associated with podcast `tokenID` and episode `episodeTokenID` owned by sender
   *
   * Requirements:
   * - `tokenID` must exist.
   * - `tokenID` must be owned by sender.
   */
  function isOwnedEpisode(uint256 tokenID, uint256 episodeTokenID) public view returns(bool) {
    _isOwned(msg.sender, tokenID);

    return episodeContract.isOwned(msg.sender, episodeTokenID);
  }

  /**
   * @dev Returns the tokenURI of the episode with `episodeTokenID`
   *
   * Requirements:
   * - `episodeTokenID` must exist.
   */
  function episodeTokenURI(uint256 episodeTokenID) public view returns (string memory) {
    return episodeContract.tokenURI(episodeTokenID);
  }

  /**
   * @dev Returns boolean of whether an arbitrary address owns a particular `tokenID`
   *
   * Requirements:
   * - `tokenID` must exist.
   * - `tokenID` must be owned by address.
   */
  function _isOwned(address _from, uint256 tokenID) internal view returns(bool) {
    _requireMinted(tokenID);

    require(_tokenToOwner[tokenID] == _from, "Invalid token owner");

    return true;
  }
}
