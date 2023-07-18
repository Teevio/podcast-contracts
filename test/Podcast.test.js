const Podcast = artifacts.require('Podcast');
const assert = require("chai").assert;
const should = require("chai").should();
const truffleAssert = require('truffle-assertions');
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

contract('Podcast', (accounts) => {
  let podcastInstance;
  const baseURI = 'https://test.localhost/'
  const contractCreatorAccount = accounts[0];
  const otherAccount = accounts[1];

  beforeEach(async () => {
    podcastInstance = await deployProxy(Podcast);
  });

  it("Creator should be able to create a podcast", async () => {
    let mint = await podcastInstance.create(baseURI, {from: contractCreatorAccount});

    assert.equal(mint.receipt.status, true, "Creator was not able to creat a podcast");
  });

  it("Non-creator should not be able to create a podcast", async () => {
    let mint = false

    try {
      // Throws an error when the account isn't the creator, which is intended behavior
      mint = await podcastInstance.create(baseURI, {from: otherAccount});
    } catch (e) {
      mint = false
    }

    assert.equal(mint, false, "Non-creator was able to create a podcast");
  });

  it("TokenURI should be set", async () => {
    let mint = await podcastInstance.create(baseURI, {from: contractCreatorAccount});

    assert.equal(await podcastInstance.tokenURI(1), `${baseURI}1/metadata.json`)
  })

  it("FeedURI should be set", async () => {
    let mint = await podcastInstance.create(baseURI, {from: contractCreatorAccount});

    assert.equal(await podcastInstance.feedURI(1), `${baseURI}1/feed.xml`)
  })

  it("Should return all owned podcasts that were created", async () => {
    await podcastInstance.create(baseURI, {from: contractCreatorAccount});
    await podcastInstance.create(baseURI, {from: contractCreatorAccount});
    await podcastInstance.create(baseURI, {from: contractCreatorAccount});

    let ownedPodcasts = await podcastInstance.getOwned({from: contractCreatorAccount})
    assert.equal(ownedPodcasts.length, 3)
  })

  it("Account should own podcast", async () => {
    await podcastInstance.create(baseURI, {from: contractCreatorAccount});

    assert.equal(await podcastInstance.isOwnedByTokenID(1, {from: contractCreatorAccount}), true)
  })

  it("Other account should not own podcast", async () => {
    let isOwned = false

    await podcastInstance.create(baseURI, {from: contractCreatorAccount});

    try {
      // Throws an error when the account is not the owner, which is intended behavior
      isOwned = await podcastInstance.isOwnedByTokenID(1, {from: otherAccount})

      assert.equal(isOwned, false)
    } catch (e) {
      assert.equal(isOwned, false)
    }
  })



  // getOwnedEpisodes
  // isOwnedEpisode
});