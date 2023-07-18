const Podcast = artifacts.require('Podcast');
const assert = require("chai").assert;
const should = require("chai").should();
const truffleAssert = require('truffle-assertions');
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

contract('Episode', (accounts) => {
  let podcastInstance;
  const baseURI = 'https://test.localhost/'
  const contractCreatorAccount = accounts[0];
  const otherAccount = accounts[1];

  beforeEach(async () => {
    podcastInstance = await deployProxy(Podcast);
  });

  it("Podcast should be able to create an episode", async () => {
    let podcastMint = await podcastInstance.create(baseURI, {from: contractCreatorAccount});

    assert.equal(podcastMint.receipt.status, true, "Creator was not able to create a podcast");

    let episodeMint = await podcastInstance.createEpisode(1, baseURI, {from: contractCreatorAccount});

    assert.equal(episodeMint.receipt.status, true, "Creator was not able to create an episode on a podcast");
  });

  it("Another account should not be able to create an episode on a podcast they don't own", async () => {
    let podcastMint = await podcastInstance.create("https://test.localhost/", {from: contractCreatorAccount});
    let episodeMint = false

    try {
      episodeMint = await podcastInstance.createEpisode(1, baseURI, {from: otherAccount});

      assert.equal(episodeMint, false, "Account was able to create an episode on a podcast they don't own");
    } catch (e) {
      assert.equal(episodeMint, false, "Account was able to create an episode on a podcast they don't own");
    }
  });

  it("Episode should have a tokenURI", async () => {
    let podcastMint = await podcastInstance.create(baseURI, {from: contractCreatorAccount});
    let episodeMint = await podcastInstance.createEpisode(1, baseURI, {from: contractCreatorAccount});

    assert.equal(await podcastInstance.episodeTokenURI(1), `${baseURI}1/episodes/1/metadata.json`)
  });

  it("Should return all episodes that were created on podcast", async () => {
    await podcastInstance.create(baseURI, {from: contractCreatorAccount});
    await podcastInstance.create(baseURI, {from: contractCreatorAccount});
    await podcastInstance.create(baseURI, {from: contractCreatorAccount});

    await podcastInstance.createEpisode(1, baseURI, {from: contractCreatorAccount});
    await podcastInstance.createEpisode(1, baseURI, {from: contractCreatorAccount});
    await podcastInstance.createEpisode(2, baseURI, {from: contractCreatorAccount});

    let ownedEpisodes = await podcastInstance.getEpisodes(1)

    assert.equal(ownedEpisodes.length, 2)
  })


  it("Should return all episodes that were created by an account", async () => {
    await podcastInstance.create(baseURI, {from: contractCreatorAccount});
    await podcastInstance.create(baseURI, {from: contractCreatorAccount});

    await podcastInstance.createEpisode(1, baseURI, {from: contractCreatorAccount});
    await podcastInstance.createEpisode(2, baseURI, {from: contractCreatorAccount});

    let ownedEpisodes = await podcastInstance.getOwnedEpisodes({from: contractCreatorAccount})
    let otherOwnedEpisodes = await podcastInstance.getOwnedEpisodes({from: otherAccount})

    assert.equal(ownedEpisodes.length, 2)

    assert.equal(otherOwnedEpisodes.length, 0)
  })
});