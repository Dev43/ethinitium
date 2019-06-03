const SimpleCrowdfundArtifact = artifacts.require("./SimpleCrowdfund");

contract('SimpleCrowdfund', function (accounts) {
  let alice = accounts[0]
  let bob = accounts[1]
  let simpleCrowdfund;

  it("should assert true", async () => {
    simpleCrowdfund = await SimpleCrowdfundArtifact.deployed();
    assert.isTrue(simpleCrowdfund.address !== "", "no address for the contract");
  });

  it("Should return the correct rate", async () => {
    let rate = await simpleCrowdfund.getRate()
    assert.equal(rate.toNumber(), 8, "Get rate returned an invalid number");
  });

  it("Should let alice buy tokens for bob", async () => {
    let balanceBob = await simpleCrowdfund.balanceOf(bob)

    assert.equal(balanceBob.toNumber(), 0, "bob should not have tokens")

    // buy tokens
    await simpleCrowdfund.buyTokens(bob, {
      from: alice,
      value: "10000"
    })

    balanceBob = await simpleCrowdfund.balanceOf(bob)
    assert.equal(balanceBob.toString(), "80000", "bob does not have the correct balance")
  });


});