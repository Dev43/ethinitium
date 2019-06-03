pragma solidity ^0.5.4;

contract Mirror {
    function() external payable {
        msg.sender.transfer(msg.value);
    }
}