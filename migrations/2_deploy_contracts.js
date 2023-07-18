const Episode = artifacts.require("Episode");
const Podcast = artifacts.require("Podcast");
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

module.exports = async function(deployer) {
  await deployProxy(Podcast, [], { deployer });

  deployer.deploy(Episode, Podcast.address);
};
