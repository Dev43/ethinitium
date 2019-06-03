pragma solidity ^0.5.4;

contract HelloWorld {
    
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

    function transfer(address payable _to) public returns (bool) {
        _to.transfer(address(this).balance);
    }

    function () payable external {}
}