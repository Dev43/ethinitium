

const Ownable = artifacts.require("./Ownable.sol");

module.exports = (deployer) => {
  deployer.deploy(Ownable);
};
