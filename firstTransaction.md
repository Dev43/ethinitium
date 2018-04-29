# Getting your very first Ether (using JSON-RPC)
## Command
```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{see above}],"id":1}'
```
## Parameters needed
```json
params: [{
  "from": "0x6787Fc48C0D68361d06C617fE5453bf83bd42888", // from address (for this to work, this address needs to be unlocked in geth)
  "to": "0x342Cd49Fc165163Dc3A873861e780ae7a05b2aC8", // to address
  "gas": "0x76c0", // 30400, total gas to send in hex
  "gasPrice": "0x9184e72a000", // 10000000000000 gas price in hex
  "value": "0xde0b6b3a7640000", // 1 ether value in hex (in Wei!!!)
  "data": "0x0" // some data to send if contract creation/function call
}]
```
### To get 1 Ether
```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{ "from": "0x6787Fc48C0D68361d06C617fE5453bf83bd42888", "to":"**<YOUR ADDRESS HERE>**", "gas": "0x76c0", "gasPrice": "0x9184e72a000", "value": "0xde0b6b3a7640000"}],"id":1}' http://138.197.137.83
```
### To look at the transaction
```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["**<TRANSACTION HASH>**"],"id":1}' http://138.197.137.83
```


### If you want to interact with you contracts EXCLUSIVELY with the terminal check this [link]
http://ethdocs.org/en/latest/contracts-and-transactions/accessing-contracts-and-transactions.html#accessing-contracts-and-transactions