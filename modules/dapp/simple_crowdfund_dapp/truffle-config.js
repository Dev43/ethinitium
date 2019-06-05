/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * truffleframework.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like truffle-hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura API
 * keys are available for free at: infura.io/register
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

const HDWalletProvider = require("truffle-hdwallet-provider");
const infuraKey = "227347f507a14ab3b95459a4ffeb613f";
// const infuraKey = process.env.INFURA_KEY;
//
// const fs = require('fs');
const mnemonic = "much repair shock carbon improve miss forget sock include bullet interest solution";
// const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
	/**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

	networks: {
		development: {
			host: "127.0.0.1",     // Localhost (default: none)
			port: 8545,            // Standard Ethereum port (default: none)
			network_id: "*",       // Any network (default: none)
		},
    
		ganache: {
			host: "127.0.0.1",     // Localhost (default: none)
			port: 7545,            // Standard Ethereum port (default: none)
			network_id: "*",       // Any network (default: none)
			gasLimit: 8000000,
			gas: 8000000,
			//  settings: {          // See the solidity docs for advice about optimization and evmVersion
			//    optimizer: {
			//      enabled: true, 
			//    },
		},

		// Useful for deploying to a public network.
		// NB: It's important to wrap the provider as a function.
		ropsten: {
			provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/${infuraKey}`),
			network_id: 3,       // Ropsten's id
			gas: 5500000,        // Ropsten has a lower block limit than mainnet
			confirmations: 0,    // # of confs to wait between deployments. (default: 0)
			timeoutBlocks: 50,  // # of blocks before a deployment times out  (minimum/default: 50)
			skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
		},
	},

	// Set default mocha options here, use special reporters etc.
	mocha: {
		// timeout: 100000
	},

	// Configure your compilers
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
