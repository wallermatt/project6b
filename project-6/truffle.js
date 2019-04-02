const HDWalletProvider = require("truffle-hdwallet-provider");

// Edit truffle.config file should have settings to deploy the contract to the Rinkeby Public Network.
// Infura should be used in the truffle.config file for deployment to Rinkeby.

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      provider: function() {
     return new HDWalletProvider(
       "spirit supply whale amount human item harsh scare congress discover talent hamster",
       "rinkeby.infura.io/v3/b272dce4f70d4710aa75acd914b7ad37")
      },
          network_id: '4',
          gas: 4500000,
          gasPrice: 10000000000,
}
  }
};