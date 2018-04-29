

# Contract Examples for the Open Source Initiative

*To be able to participate in the hands-on section of the course, please download the Mist Browser on your machine. Please download **version 0.8.9** as the latest release won't let us access the node using RPC over HTTP.

The Mist releases can be found here:

https://github.com/ethereum/mist/releases

Choose the right package depending on your operating system and architecture.


## Windows Users

Download the correct .zip file
Extract the file into a chosen folder
Go in the folder
Click on Mist.exe

And voila!

Note: By clicking on Mist.exe, the Mist browser should execute and will start downloading the Ethereum Blockchain (the real one!). As this is multiple Gigs of data, and we don't want you to go over your expensive bandwidth allocation, **close it and forget it** until Sunday.

## Mac Users

Download the .dmg
Either install Mist using your terminal : http://apple.stackexchange.com/questions/73926/is-there-a-command-to-install-a-dmg
Or using Applications: https://www.howtogeek.com/177619/how-to-install-applications-on-a-mac-everything-you-need-to-know/

And voila!

By clicking on the application, the Mist browser should execute and will start downloading the Ethereum Blockchain (the real one!). As this is multiple Gigs of data, and we don't want you to go over your expensive bandwidth allocation, **close it and forget it** until Sunday.
*********************************************************************************************
## Linux Users

Download the .deb
Go in a terminal, go to the file directory (most likely /home/<NAMEOFCOMP>/Downloads)
Execute the command `sudo dpkg -i <name_of_package>`
And voila!

By clicking on the application, the Mist browser should execute and will start downloading the Ethereum Blockchain (the real one!). As this is multiple Gigs of data, and we don't want you to go over your expensive bandwidth allocation, **close it and forget it** until Sunday.
*********************************************************************************************

Building from source

Want to make your life a bit harder?

You can also download Mist from source here:

https://github.com/ethereum/mist

Make sure you choose the right tag 
```bash
git clone https://github.com/ethereum/mist.git
cd mist
git checkout v0.8.9
yarn
``` 

If you have any questions regarding installation, please email me at patrick.guay43@gmail.com


To connect to the private testnet, when executing the application (through command line), add the flag "--rpc" with this address:"http://138.197.137.83"

So in LINUX it should look like

`mist --rpc http://138.197.137.83`


In Windows

`Mist.exe --rpc http://138.197.137.83`

in Mac 
In a terminal : 
`/Applications/Mist.app/Contents/MacOS/Mist --rpc http://138.197.137.83`


Why are we doing this? This way you don't need to download the private blockchain (all of the block up until now) onto your own computer to synchronize. The blockchain protocol is running on a virtual computer on the cloud, and Mist will be our GUI to interact with it.


*************************************************************************************************

# Addresses and ABI's

## Hello World Contract

Address: 0xa1E0FB73C95A19732e04e40497c387A036795740

Contract's ABI:
```json
[ { "payable": true, "type": "fallback" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "out", "type": "string" } ], "name": "Print", "type": "event" } ]
```
----------------------------------------------------------------------------------------------------

## Ballot contract :

Address :  0x849A26b8e7b4858118E96e04BB23635ad4acF144

Contract's ABI:
```json
[ { "constant": false, "inputs": [ { "name": "proposal", "type": "uint256" } ], "name": "vote", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "uint256" } ], "name": "proposals", "outputs": [ { "name": "name", "type": "string", "value": "Covfefe" }, { "name": "description", "type": "string", "value": "Make Covfefe an official word in the Dictionnary" }, { "name": "voteCount", "type": "uint256", "value": "0" } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "newProposal", "type": "string" }, { "name": "desc", "type": "string" } ], "name": "addProposal", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [], "name": "creatorPayday", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "chairperson", "outputs": [ { "name": "", "type": "address", "value": "0x022f686b85ea576d4684280b3195f1ec3546c28f" } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "voter", "type": "address" } ], "name": "removeRightToVote", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [], "name": "destroy", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "address" } ], "name": "voters", "outputs": [ { "name": "voted", "type": "bool", "value": false }, { "name": "vote", "type": "uint256", "value": "0" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "balance", "outputs": [ { "name": "", "type": "uint256", "value": "0" } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [], "name": "donateToCreator", "outputs": [], "payable": true, "type": "function" }, { "constant": true, "inputs": [], "name": "winnerName", "outputs": [ { "name": "winnerName", "type": "string", "value": "Covfefe" } ], "payable": false, "type": "function" }, { "inputs": [], "payable": false, "type": "constructor" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "who", "type": "address" }, { "indexed": false, "name": "voteCalc", "type": "uint256" } ], "name": "Voted", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "from", "type": "address" }, { "indexed": false, "name": "chair", "type": "address" }, { "indexed": false, "name": "amount", "type": "uint256" } ], "name": "Donation", "type": "event" } ]
```

----------------------------------------------------------------------------------------------------

## NHLPredictor Contract

Address: 0x98f3c20949A5449F9Ae245EFd85b0d3D0c2477b9

Contract's ABI:
```json
[ { "constant": false, "inputs": [ { "name": "_forTeam", "type": "string" }, { "name": "_conference", "type": "string" }, { "name": "length", "type": "uint256" } ], "name": "placeBet", "outputs": [], "payable": true, "type": "function" }, { "constant": true, "inputs": [], "name": "isWinner", "outputs": [ { "name": "", "type": "bool", "value": false } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "myid", "type": "bytes32" }, { "name": "result", "type": "string" } ], "name": "__callback", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "myid", "type": "bytes32" }, { "name": "result", "type": "string" }, { "name": "proof", "type": "bytes" } ], "name": "__callback", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "_division", "type": "string" } ], "name": "getWinnerPerDivision", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [], "name": "addToBet", "outputs": [], "payable": true, "type": "function" }, { "constant": false, "inputs": [], "name": "claimPrize", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [], "name": "destroy", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "address" } ], "name": "allBets", "outputs": [ { "name": "init", "type": "bool", "value": false }, { "name": "leadingTeam", "type": "string", "value": "" }, { "name": "conference", "type": "string", "value": "" }, { "name": "betBalance", "type": "uint256", "value": "0" }, { "name": "betLength", "type": "uint256", "value": "0" } ], "payable": false, "type": "function" }, { "inputs": [ { "name": "_oraclizeAddressResolver", "type": "address", "index": 0, "typeShort": "address", "bits": "", "displayName": "&thinsp;<span class=\"punctuation\">_</span>&thinsp;oraclize Address Resolver", "template": "elements_input_address", "value": "0xE8F849c8a68E08350242E7834bD03F75aECf3429" } ], "payable": false, "type": "constructor" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "_betPlaced", "type": "string" }, { "indexed": false, "name": "_team", "type": "string" }, { "indexed": false, "name": "conference", "type": "string" }, { "indexed": false, "name": "_amountBet", "type": "uint256" } ], "name": "BetPlaced", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "_desc", "type": "string" }, { "indexed": false, "name": "_by", "type": "uint256" }, { "indexed": false, "name": "_total", "type": "uint256" } ], "name": "BetIncreased", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "_to", "type": "address" }, { "indexed": false, "name": "_amount", "type": "uint256" } ], "name": "Paid", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "desc", "type": "string" }, { "indexed": false, "name": "result", "type": "string" } ], "name": "OraclizeCalledBack", "type": "event" } ]
```
----------------------------------------------------------------------------------------------------

## Kraken Price Ticker Contract

Address: 0x4Db9CBd372f070bAbc792a20810802ddfE6dc295

Contract's ABI:
```json
[ { "constant": false, "inputs": [ { "name": "myid", "type": "bytes32" }, { "name": "result", "type": "string" } ], "name": "__callback", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "myid", "type": "bytes32" }, { "name": "result", "type": "string" }, { "name": "proof", "type": "bytes" } ], "name": "__callback", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [], "name": "update", "outputs": [], "payable": true, "type": "function" }, { "constant": true, "inputs": [], "name": "ETHXBT", "outputs": [ { "name": "", "type": "string", "value": "0.118220" } ], "payable": false, "type": "function" }, { "inputs": [ { "name": "_oraclizeAddressResolver", "type": "address", "index": 0, "typeShort": "address", "bits": "", "displayName": "&thinsp;<span class=\"punctuation\">_</span>&thinsp;oraclize Address Resolver", "template": "elements_input_address", "value": "0xE8F849c8a68E08350242E7834bD03F75aECf3429" } ], "payable": false, "type": "constructor" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "description", "type": "string" } ], "name": "newOraclizeQuery", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "price", "type": "string" } ], "name": "newKrakenPriceTicker", "type": "event" } ]
```