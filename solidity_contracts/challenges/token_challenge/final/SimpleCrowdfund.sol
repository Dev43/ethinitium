

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
    function SimpleCrowdfund(uint256 _maxSupply, uint256 _toMint, address _ownerWallet) public {
        maxSupply = _maxSupply;
        ownerWallet = _ownerWallet;
        require(mint(msg.sender, _toMint));
        startBlock = block.number;
    }

    // Function that actually buys the tokens
    function buyTokens(address _to) public payable returns (bool) {
        // Crowdsfund ends if current block number is abve 2000
        require(block.number > startBlock + 2000);
        // Ensure the address passed is valid
        require(address(_to) != address(0));
        // Get the amount of tokens
        uint256 amount = msg.value.mul(getRate());
        // Ensure the minting works
        require(mint(_to, amount));
        // Transfer to the owner wallet the ETH sent
        ownerWallet.transfer(msg.value);
        // Emist an event
        emit TokenPurchase(_to, amount);
        return true;
    }

    // GetRate returns the rate of the tokens based on the current block
    function getRate() public view returns (uint256) {

        if (block.number > (startBlock + 1000)) {
            return 5;
        } else if (block.number > (startBlock + 750)) {
            return 6;
        } else if (block.number > (startBlock + 500)) {
            return 7;
        } else {
            return 8;
        }
    }

    // If user simply send ETH, call buy tokens with the message sender
    function() public payable {
        buyTokens(msg.sender);
    }

}

