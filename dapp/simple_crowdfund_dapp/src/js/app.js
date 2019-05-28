

App = {
    currentAccount: '0x0',
    web3: {},
    SimpleCrowdfund: {},
    initialized: false,
    currentNetwork: "4447", // 3 is ropsten

    initialize: async function () {
        // first we check if web3 is present
        if (typeof web3 !== 'undefined') {
            this.web3 = new Web3(web3.currentProvider);
            ethereum.enable()
            let network = await this.web3.currentProvider.networkVersion
            if (network != this.currentNetwork) {
                $("#loading").hide()
                $('#error').text("Please make sure your network is set to Ropsten");
                return
            }
            let accounts = await new Promise((resolve, reject) => {
                this.web3.eth.getAccounts((err, accounts) => {
                    if (err != null) {
                        reject(err)
                    }
                    resolve(accounts)
                })
            })
            if (accounts.length == 0) {
                $("#loading").hide()
                $('#error').text("No valid account selected, please refresh");
                return
            }
            this.currentAccount = accounts[0]
        } else {
            $('#error').text("Please make sure metamask is unlocked and on the Ropsten Network");
        }
        $("#loading").hide()

        console.log("Web3 successfully Initialized")
        console.log("Initializing SimpleCrowdfund contract")

        $.getJSON("SimpleCrowdfund.json", (crowdfund) => {
            if (!crowdfund.networks[this.currentNetwork]) {
                $('#error').text("Simple Crowdfund was not deployed to Ropsten or Address is missing in SimpleCrowdfund.json build file");
                return
            }
            console.log(this.web3)
            this.SimpleCrowdfund = TruffleContract({ abi: crowdfund.abi, address: crowdfund.networks[this.currentNetwork].address })
            this.SimpleCrowdfund.setProvider(this.web3.currentProvider)


            console.log("Contract successfully Initialized")
            this.initialized = true;
        })

    },
}

$(function () {
    $(window).load(function () {
        App.initialize();
    })
});