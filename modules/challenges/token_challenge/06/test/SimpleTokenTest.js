const truffleAssert = require('truffle-assertions');
const SafeMath = artifacts.require("SafeMath");
const SimpleCrowdfund = artifacts.require("SimpleCrowdfund");
const SimpleToken = artifacts.require("SimpleToken");
const ProxySafeMath = artifacts.require("ProxySafeMath");

contract("SimpleToken",(accounts)=>{
  let trace = false;
  let contractSafeMath = null;
  let contractSimpleToken = null;
  let contractSimpleCrowdfund = null;
  beforeEach(async () => {
    contractSafeMath = await SafeMath.new({from: accounts[0]});
    if(trace) console.log('SUCESSO: SafeMath.new({from: accounts[0]}');
    SimpleToken.link("SafeMath",contractSafeMath.address);
    contractSimpleToken = await SimpleToken.new({from: accounts[0]});
    if(trace) console.log('SUCESSO: SimpleToken.new({from: accounts[0]}');
    contractSimpleCrowdfund = await SimpleCrowdfund.new(1000,9,{from:accounts[0]});
    if(trace) console.log('SUCESSO: SimpleCrowdfund.new(1000,9,{from:accounts[0]}');
  });
  
  it('Should execute transferFrom(address,address,uint256)', async () => {
    let result = await contractSimpleToken.transferFrom(accounts[7], accounts[8], 500,{from: accounts[0]});
  });
  it('Should execute approve(address,uint256)', async () => {
    let result = await contractSimpleToken.approve(accounts[8], 2001,{from: accounts[0]});
  });
  it('Should execute allowance(address,address)', async () => {
    let result = await contractSimpleToken.allowance(accounts[4], accounts[9],{from: accounts[0]});
  });
  it('Should execute balanceOf(address)', async () => {
    let result = await contractSimpleToken.balanceOf(accounts[7],{from: accounts[0]});
  });
  it('Should execute transfer(address,uint256) WHEN _to!=0x0000000000000000000000000000000000000000,_value<=balances', async () => {
    let result = await contractSimpleToken.transfer(accounts[6], 0,{from: accounts[0]});
  });
  it('Should fail transfer(address,uint256) when NOT comply with: _to != 0x0000000000000000000000000000000000000000', async () => {
    let result = await truffleAssert.fails(contractSimpleToken.transfer("0x0000000000000000000000000000000000000000", 0,{from: accounts[0]}),'revert');
  });
  it('Should execute mint(address,uint256) WHEN msg.sender==_owner,totalSupply<maxSupply', async () => {
    let result = await contractSimpleToken.mint(accounts[3], 6,{from: accounts[0]});
  });
  it('Should fail mint(address,uint256) when NOT comply with: msg.sender == _owner', async () => {
    let result = await truffleAssert.fails(contractSimpleToken.mint(accounts[3], 6,{from: accounts[9]}),'revert');
  });
  it('Should execute owner()', async () => {
    let result = await contractSimpleToken.owner({from: accounts[0]});
  });
  it('Should execute isOwner()', async () => {
    let result = await contractSimpleToken.isOwner({from: accounts[0]});
  });
  it('Should execute renounceOwnership() WHEN msg.sender==_owner', async () => {
    let result = await contractSimpleToken.renounceOwnership({from: accounts[0]});
  });
  it('Should fail renounceOwnership() when NOT comply with: msg.sender == _owner', async () => {
    let result = await truffleAssert.fails(contractSimpleToken.renounceOwnership({from: accounts[9]}),'revert');
  });
  it('Should execute transferOwnership(address) WHEN msg.sender==_owner,newOwner!=0x0000000000000000000000000000000000000000', async () => {
    let result = await contractSimpleToken.transferOwnership(accounts[0],{from: accounts[0]});
  });
  it('Should fail transferOwnership(address) when NOT comply with: msg.sender == _owner', async () => {
    let result = await truffleAssert.fails(contractSimpleToken.transferOwnership(accounts[0],{from: accounts[9]}),'revert');
  });
  it('Should fail transferOwnership(address) when NOT comply with: newOwner != 0x0000000000000000000000000000000000000000', async () => {
    let result = await truffleAssert.fails(contractSimpleToken.transferOwnership("0x0000000000000000000000000000000000000000",{from: accounts[0]}),'revert');
  });
});
