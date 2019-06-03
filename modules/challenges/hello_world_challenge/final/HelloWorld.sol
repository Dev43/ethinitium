pragma solidity ^0.5.4;

contract HelloWorld {

    address owner;
    
    constructor() internal {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Message sender is not the owner");
        _;
    }
    
    function set(uint _value) public {
        value = _value;
    }

    function get() public view returns (uint) {
        return value;
    }

    uint value;

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    function transfer(address payable _to) public onlyOwner returns (bool) {
        _to.transfer(address(this).balance);
    }

    function () payable external {}
}