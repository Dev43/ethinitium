

App = {
    currentAddress: '0x0',
    web3: {},
    SimpleCrowdfund: {},
    initialized: false,
    currentNetwork: "3", // 3 is ropsten CHANGE ME

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
            console.log(this.web3)
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
            this.currentAddress = accounts[0]
            $("#currentAddress").text(`Current Address: ${this.currentAddress}`)
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
            let contract = TruffleContract({ abi: crowdfund.abi, address: crowdfund.networks[this.currentNetwork].address })
            contract.setProvider(this.web3.currentProvider)
            contract.at(crowdfund.networks[this.currentNetwork].address).then((instance) => {
                this.SimpleCrowdfund = instance
                console.log("Contract successfully Initialized")
                this.initialized = true;
                console.log(this.SimpleCrowdfund)
                this.getTokenInformation()
            }).catch((e) => {
                console.log(e)
                alert(e)
            })
        })

    },

    buyTokens: async function () {
        let amount = $('.buyTokens input[name=amount]').val()
        let tx
        try {
            tx = await this.SimpleCrowdfund.buyTokens(this.currentAddress, { from: this.currentAddress, value: amount })
        } catch (e) {
            alert(e)
            return
        }
    },

    getRate: async function () {
        let rate = await this.SimpleCrowdfund.getRate()
        $('#currentRate').text(rate.toString())
    },

    getBalance: async function() {
        let address = $('.getBalance input[name=address]').val()
        let balance
        try {
            balance = await this.SimpleCrowdfund.balanceOf(this.currentAddress, { from: this.currentAddress })
        } catch (e) {
            alert(e)
            return
        }

        $('#balance').text(balance.toString())


    },

    transfer: async function() {
        let address = $('.transfer input[name=address]').val()
        let amount = $('.transfer input[name=amount]').val()
        console.log(address, amount)
        let tx
        try {
            tx = await this.SimpleCrowdfund.transfer(address, amount, { from: this.currentAddress })
        } catch (e) {
            alert(e)
            return
        }
    },

    getTokenInformation: async function() {
        let name = await this.SimpleCrowdfund.name()
        let owner = await this.SimpleCrowdfund.owner()
        let symbol = await this.SimpleCrowdfund.symbol()
        let decimals = await this.SimpleCrowdfund.decimals()
        let totalSupply = await this.SimpleCrowdfund.totalSupply()

        $('.tokenInfo #name').text(`Name: ${name}`)
        $('.tokenInfo #symbol').text(`Symbol: ${symbol}`)
        $('.tokenInfo #decimals').text(`Decimals: ${decimals}`)
        $('.tokenInfo #totalSupply').text(`TotalSupply: ${totalSupply}`)
        $('.tokenInfo #owner').text(`Owner: ${owner}`)

    }
}

$(function () {
    $(window).load(function () {
        App.initialize();
    })
});