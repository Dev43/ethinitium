//jshint ignore: start

const BikeShare = artifacts.require('../contracts/BikeShare.sol');

contract('BikeShare', function(accounts) {

  const owner = accounts[0];
  const random = accounts[1];
  const bob = accounts[2];
  let bikeshare;


  it('should deploy', async () => {
    bikeshare = await BikeShare.new({from: owner});
  });

  it('should be deployed', async () => {

    assert(bikeshare.address !== undefined, 'Bike was not deployed');
  });

  it('should be able purchase credits', async () => {
    const tx = await bikeshare.sendTransaction({
      from: owner,
      value: web3.toWei(1, 'ether')
    });
    //state should be updated
    const credits = await bikeshare.credits.call(owner);
    //credits is of type BigNumber
    assert(credits.equals(1000), 'Wrong amount of credits');
  });

  it('should be able to rent bike 2', async () => {
    const tx = await bikeshare.rentBike(2, { from: owner });
    //wait until the bike was rented
    const bike = await bikeshare.bikeRented.call(owner);
    const isRented = await bikeshare.getAvailable.call();


    assert(bike.equals(2), 'Bike 2 not rentable');
    assert(isRented[2], 'Bike 2 not rentable');
  });


  it('should be able to ride bike 2', async () => {
    const tx = await bikeshare.rideBike(25);
    const credits = await bikeshare.credits(owner);

    assert(credits.equals(875), 'Wrong amount of credits');
  });

  //owner credits === 875
  it('should be able to return bike 2 with 25kms', async () => {
    const tx = await bikeshare.returnBike();
    //wait for state
    const bike = await bikeshare.bikes.call(2);
    const available = await bikeshare.getAvailable.call();

    assert(bike[2].equals(25), 'Bike 2 incorrect kms');
    assert(!available[2], 'Bike 2 not rentable');
  });

});