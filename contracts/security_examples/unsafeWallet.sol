pragma solidity ^0.4.8;

/*
/////////////////////////////// UNSAFE WALLET //////////////////////////////////////
/////////////////////////////// NEVER TO BE USED ///////////////////////////////////
*/
contract UnsafeWallet {

    mapping(address => uint) balances;

    function UnsafeWallet() payable {
        // when creating the contract, the creator can send money along with it, this will initialize his balance
        balances[msg.sender] = msg.value;
    }
    // Withdraw your balance.
    function withdraw() returns(bool){
        uint toWithdraw = balances[msg.sender];
        // .call returns true if completed, false otherwise
        // the biggest flaw here is that .call() gives all of the remaining gas to the recipient
        // thus a re-entrancy attack can be done again and again
        if (msg.sender.call.value(toWithdraw)()){
            balances[msg.sender] = 0;
            return true;
        }
        return false;
    }

    function deposit() payable returns(bool) {
        balances[msg.sender] += msg.value;
        return true;
    }

   function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
}
