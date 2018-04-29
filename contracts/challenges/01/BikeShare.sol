

pragma solidity ^0.4.21;


contract BikeShare {

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