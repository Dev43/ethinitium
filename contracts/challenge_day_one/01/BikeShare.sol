

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
    function rentBike()  {}

    /**************************************
    * Ride a bike
    **************************************/
    function rideBike() {}

    /**************************************
    * Return the bike
    **************************************/
    function returnBike() {}

    /**************************************
    * default payable function, will call purchaseCredits
    **************************************/
    function() {}
}

/*
  THIS CONTRACT IS ONLY MEANT TO BE USED FOR EDUCATIONAL PURPOSES. ANY AND ALL USES IS
  AT A USER'S OWN RISK AND THE AUTHOR HAS NO RESPONSIBILITY FOR ANY LOSS OF ANY KIND STEMMING
  THIS CODE.
 */