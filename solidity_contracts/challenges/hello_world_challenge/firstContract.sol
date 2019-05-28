pragma solidity ^0.4.18;
contract SimpleStore {
    function set(uint _value) public {
        value = _value;
    }

    function get() public constant returns (uint) {
        return value;
    }

    uint value;

    function amountOfEther() public view returns (uint256) {
        return this.balance;
    }

    function transferEther(address _to) public returns (bool) {
        _to.transfer(this.balance);
    }

    function () payable public {}
}