const SimpleCrowdfund = artifacts.require("SimpleCrowdfund");

module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(SimpleCrowdfund, 1000000, 100)
};
