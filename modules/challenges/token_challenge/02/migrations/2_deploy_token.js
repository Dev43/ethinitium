const SimpleToken = artifacts.require("SimpleToken");

module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(SimpleToken)
};
