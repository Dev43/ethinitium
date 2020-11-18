const truffleAssert = require('truffle-assertions');
const SafeMath = artifacts.require("SafeMath");
const SimpleCrowdfund = artifacts.require("SimpleCrowdfund");
const SimpleToken = artifacts.require("SimpleToken");
const ProxySafeMath = artifacts.require("ProxySafeMath");

contract("SimpleCrowdfund",(accounts)=>{
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
  
  it('Should execute buyTokens(address)', async () => {
    let result = await contractSimpleCrowdfund.buyTokens(accounts[3],{from: accounts[0]});
  });
  it('Should execute getRate()', async () => {
    let result = await contractSimpleCrowdfund.getRate({from: accounts[0]});
  });
  it('Should execute fallback()', async () => {
    let result = await contractSimpleCrowdfund.sendTransaction({from: accounts[0],value:6});
  });
});
