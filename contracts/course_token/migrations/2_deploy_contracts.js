

const CourseToken = artifacts.require("./CourseToken.sol");

module.exports = (deployer) => {
  deployer.deploy(CourseToken);
};
