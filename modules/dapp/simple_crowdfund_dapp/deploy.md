# Deploy to IPFS checklist

- [ ] Deploy contract to Ropsten
- [ ] Create a new directory called `dist`
- [ ] Add in the `build/contracts/SimpleCrowdfund.json` to the dist folder
- [ ] Add in everything inside of `src` into the dist folder `cp -r src/* dist`
- [ ] Make sure the app.js in the Dist folder has `currentNetwork: "3"` set
- [ ] Do `ipfs add -r dist` 0x3baA64a4401Bbe18865547E916A9bE8e6dD89a5A
- [ ] `ipfs name publish HASH`