

pragma solidity ^0.4.21;


import "../../../library/Ownable.sol";
import "../../../library/SafeMath.sol";



contract BikeShare is Ownable {

    using SafeMath for uint256;
    /**************************************
    * State variables
    **************************************/
    // "Type" Bike, holds the owner, whether it is rented, and
    // the amount of kilometers ridden
    struct Bike {
        address owner;
        bool isRented;
        uint256 kms;
    }

    // Array of said bikes
    Bike[] public bikes;

    // Mapping to keep track of the bikes rented
    mapping(address => uint256) public bikeRented;

    // Mapping to keep track of user's credit balances
    mapping(address => uint256) public credits;

    // Initial credit price
    uint256 internal creditPrice = 1 finney;
    // Initial cost per kilometer
    uint256 internal cpkm = 5;
    // Initial credits received for donating a bike
    uint256 internal donateCredits = 500;
    // Initial credits given for repairing a bike
    uint256 internal repairCredits = 250;

    /**************************************
    * constructor
    **************************************/
    function BikeShare() public {
      // Initialize with 5 bikes from the bikeshare owner
        for (uint8 i = 0; i < 5; i++) {
            bikes.push(Bike({ owner: msg.sender, isRented: false, kms: 0 }));
        }
    }

    /**************************************
    * Events
    **************************************/
    event Donation(address _from, uint256 _amount);
    event CreditsPurchased(address indexed _to, uint256 _ethAmount, uint256 _creditAmount);
    event BikeRented(address _renter, uint256 indexed _bikeNumber);
    event BikeRidden(address _renter, uint256 indexed _bikeNumber, uint256 _kms);
    event BikeReturned(address _renter, uint256 indexed _bikeNumber);

    /**************************************
    * Modifiers
    **************************************/
    modifier canRent(uint256 _bikeNumber) {
        require(bikeRented[msg.sender] == 0 && !bikes[_bikeNumber].isRented);
        _;
    }
    modifier hasRental() {
        require(bikeRented[msg.sender] != 0);
        _;
    }
    modifier hasEnoughCredits(uint256 _kms) {
        require(credits[msg.sender].sub(_kms.mul(cpkm)) > 0);
        _;
    }


    /**************************************
    * Functions only accessible by the owner
    **************************************/
    function setCreditPrice(uint256 _creditPrice) onlyOwner external { creditPrice = _creditPrice; }
    function setCPKM(uint256 _cpkm) onlyOwner external { cpkm = _cpkm; }
    function setDonateCredits(uint256 _donateCredits) onlyOwner external { donateCredits = _donateCredits; }
    function setRepairCredits(uint256 _repairCredits) onlyOwner external { repairCredits = _repairCredits; }

    /**************************************
    * getters not provided by compiler
    **************************************/
    function getAvailable() public view returns (bool[]) {
        bool[] memory available = new bool[](bikes.length);
        //loop begins at index 1, never rent bike 0
        for (uint8 i = 1; i < bikes.length; i++) {
            if (bikes[i].isRented) {
                available[i] = true;
            }
        }
        return available;
    }
   /**************************************
    * Function to get the credit balance of a user
    **************************************/
    function getCreditBalance(address _addr) public view returns (uint256) {
        return credits[_addr];
    }
    /**************************************
    * Function to purchase Credits
    **************************************/
    function purchaseCredits() private {
        // Calculate the amount of credits the user will get
        // NOTE: integer division floors the result
        uint256 amount = msg.value.div(creditPrice);
        // Add to the amount of credits the user has
        emit CreditsPurchased(msg.sender, msg.value, amount);
        credits[msg.sender] = credits[msg.sender].add(amount);
    }

    /**************************************
    * Donating function
    **************************************/
    function donateBike() external {
        bikes.push(Bike({ owner: msg.sender, isRented: false, kms: 0 }));
        credits[msg.sender] = credits[msg.sender].add(donateCredits);
        emit Donation(msg.sender, donateCredits);
    }
    /**************************************
    * Rent a bike
    **************************************/
    function rentBike(uint256 _bikeNumber) external canRent(_bikeNumber) {
        bikeRented[msg.sender] = _bikeNumber;
        bikes[_bikeNumber].isRented = true;
        emit BikeRented(msg.sender, _bikeNumber);
    }
    /**************************************
    * Ride a bike
    **************************************/
    function rideBike(uint256 _kms) external hasRental hasEnoughCredits(_kms) {
        bikes[bikeRented[msg.sender]].kms = bikes[bikeRented[msg.sender]].kms.add(_kms);
        credits[msg.sender] = credits[msg.sender].sub(_kms.mul(cpkm));
        emit BikeRidden(msg.sender, bikeRented[msg.sender], _kms);
    }
    /**************************************
    * Return the bike
    **************************************/
    function returnBike() external hasRental {
        bikes[bikeRented[msg.sender]].isRented = false;
        bikeRented[msg.sender] = 0;
        emit BikeReturned(msg.sender, bikeRented[msg.sender]);

    }
    /**************************************
    * This function sends all of the ETh locked in
    the contract to the owner
    **************************************/
    function sendToOwner() external onlyOwner returns (bool) {
        msg.sender.transfer(address(this).balance);
        return true;
    }

    /**************************************
    * default payable function, will call purchaseCredits
    **************************************/
    function() payable public {
        purchaseCredits();
    }

    // Challenge 1: Refactor the code so we only use 1 mapping
    // Challenge 2: Bikers should be able to transfer credifts to a friend
    // Challenge 3: As of right now, the Ether is locked in the contract and cannot move,
    // make the Ether transferrable to your address immediately upon receipt

    // Advanced challenge 1: Decouple the "database" aka mapping into another contract.
    // Advanced challenge 2: Include an overflow protection library (or inherit from a contract)
    // Advanced challenge 3: Develop an efficient way to track and store kms per rental, per user
    // Advanced challenge 4: Add a repair bike bounty where the work can be claimed by a user and verified by another user
    // Advanced challenge 5: Allow all users to vote on how many credits should be given for a donated bike within a time frame

}

/*
  THIS CONTRACT IS ONLY MEANT TO BE USED FOR EDUCATIONAL PURPOSES. ANY AND ALL USES IS
  AT A USER'S OWN RISK AND THE AUTHOR HAS NO RESPONSIBILITY FOR ANY LOSS OF ANY KIND STEMMING
  THIS CODE.
 */
