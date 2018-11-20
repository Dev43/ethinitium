var plasma = artifacts.require("./PlasmaMVP.sol");

module.exports = function(deployer) {
  deployer.deploy(plasma);
};
