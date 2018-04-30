

pragma solidity ^0.4.21;

import "./SimpleToken.sol";

contract SimpleCrowdfund is SimpleToken {

    // Token purchase event
    event TokenPurchase(address indexed _buyer, uint256 _value);

    // OwnerWallet address, all ETH gets transfered to him automatically
    address ownerWallet;
    // StartBlock is the block where the contract gets mined
    uint256 startBlock;

    // Constructor function
    function SimpleCrowdfund() public {

    }

    // Function that actually buys the tokens
    function buyTokens(address _to) public returns (bool) {}

    // GetRate returns the rate of the tokens based on the current block
    function getRate() public view returns (uint256) {}

    // If user simply send ETH, call buy tokens with the message sender
    function() public {}

}

