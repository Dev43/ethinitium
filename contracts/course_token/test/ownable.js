

//jshint ignore: start

const Ownable = artifacts.require('./Ownable.sol');

//const BigNumber = require('bignumber.js');

contract('Ownable', function(accounts) {
  
  let contract;
  const owner = accounts[0];
  const random = accounts[1];
  
  const oneEther = web3.toBigNumber(web3.toWei(1, 'ether'));
  
  it('should be deployed', async () => {
    contract = await Ownable.deployed();
    assert(contract.address !== undefined, 'Ownable was not deployed');
  });
  
});
