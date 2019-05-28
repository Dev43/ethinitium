module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  compilers: {
    solc: {
      version: "0.5.4",    // Fetch exact version from solc-bin (default: truffle's version)
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
};
