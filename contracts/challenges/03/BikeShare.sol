

pragma solidity ^0.4.21;


contract BikeShare {


    /**************************************
    * State variables
    **************************************/
    // "Type" Bike, holds the owner, whether it is rented, and
    // the amount of kilometers ridden
    struct Bike {
      address owner;
      bool isRented;
      uint32 kms;
    }

    // Array of said bikes
    Bike[] public bikes;

    // Mapping to keep track of the bikes rented
    mapping(address => uint32) public bikeRented;

    // Mapping to keep track of user's credit balances
    mapping(address => uint256) public credits;

    // Initial credit price
    uint256 creditPrice = 1 finney;
    // Initial cost per kilometer
    uint256 cpkm = 5;
    // Initial credits received for donating a bike
    uint256 donateCredits = 500;
    // Initial credits given for repairing a bike
    uint256 repairCredits = 250;

    /**************************************
    * constructor
    **************************************/
    function BikeShare() {

    }

    /**************************************
    * Functions only accessible by the owner
    **************************************/
    function setCreditPrice()  {}
    function setCPKM()  {}
    function setDonateCredits()  {}
    function setRepairCredits()  {}

    /**************************************
    * getters not provided by compiler
    **************************************/
    function getAvailable(){}

    /**************************************
    * Function to purchase Credits
    **************************************/
    function purchaseCredits() {}

    /**************************************
    * Donating function
    **************************************/
    function donateBike() {}

    /**************************************
    * Rent a bike
    **************************************/
    function rentBike() canRent(_bikeNumber) {}

    /**************************************
    * Ride a bike
    **************************************/
    function rideBike() hasRental hasCredits(_kms) {}

    /**************************************
    * Return the bike
    **************************************/
    function returnBike() hasRental {}

    /**************************************
    * default payable function, will call purchaseCredits
    **************************************/
    function() {}
}