require('dotenv').config()
const path = require('path')
const HDWalletProvider = require('@truffle/hdwallet-provider')
const { STAGE_INFURA_API_KEY, STAGE_PRIVATE_KEY, PROD_INFURA_API_KEY, PROD_PRIVATE_KEY, FROM_ADDRESS } = process.env

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: "../dash.amplicu.be/src/contracts",
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
    goerli: {
      provider: () => new HDWalletProvider({
        privateKeys: [STAGE_PRIVATE_KEY],
        providerOrUrl: STAGE_INFURA_API_KEY,
        numberOfAddresses: 1,
        shareNonce: true
      }),
      network_id: '5',
      gas: 4000000
    },
    live: {
      provider: () => new HDWalletProvider({
        privateKeys: [PROD_PRIVATE_KEY],
        providerOrUrl: PROD_INFURA_API_KEY,
        numberOfAddresses: 1,
        shareNonce: true
      }),
      from: FROM_ADDRESS,
      network_id: '1',
      // gas: 6400000,
      skipDryRun: true,
      production: true
    }
  },
  compilers: {
    solc: {
      version: "^0.8.0",
      settings: {
        optimizer: {
          runs: 200,
          enabled: true
        }
      }
    }
  }
};
