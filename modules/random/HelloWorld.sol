pragma solidity ^0.5.4;

contract HelloWorld {

    uint value;
    
    function set(uint _value) public {
        value = _value;
    }

    function get() public view returns (uint) {
        return value;
    }
    
}