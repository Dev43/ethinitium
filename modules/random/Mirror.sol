pragma solidity 0.5.4;

contract Mirror {
    uint256 txCount = 0;
    event Winner(address sender, uint256 amount);
    
    function () external payable {
        require(msg.value > 0.01 ether, "you need to send at least 0.01 ether");
        if(txCount % 10 == 0) {
            uint256 amount = address(this).balance;
            // win
            msg.sender.transfer(amount);
            emit Winner(msg.sender, amount);
            return;
        }
        // remove 0.01 ether
        msg.sender.transfer(msg.value - 0.01 ether);
    }


}