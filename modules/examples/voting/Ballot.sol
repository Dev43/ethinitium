// Tell the compiler which version of the compiler we are using
pragma solidity ^0.4.8;

//  Simple Voting Contract.
contract Ballot {
    // Events are our Dapp's window into what is happening in our smart contract
    // They are cheap to create, and saved in such a way that it is fast to find
    event Voted(address who, uint voteCalc);
    event Donation(address from, address chair, uint amount);


  // This declares a new complex type which will
  // be used for variables later.
  // It will represent a single voter.
    struct Voter {
        bool voted;  // if true, the person already voted
        uint vote;   // index of the voted proposal
    }

    // This is a type for a single proposal.
    struct Proposal  {
        string name;   // short name for the proposal (up to 32 bytes)
        string description; // description of the proposal
        uint voteCount; // number of accumulated votes
    }

    // Modifiers allow us to write reusable code
    // they are especially good for authentication
    // the _; tells the compiler where to put the rest of the code
    modifier isCreator(){
      if(msg.sender != chairperson){
        throw;
      }
      _;
    }

    // This declares a state variable that
    // Here we track the total balance of the contract
    uint public balance = 0;

    // Chairperson will be the creator of the contract
    address public chairperson;

    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;

    // A dynamically-sized array of `Proposal` structs.
    // note the 'public' keyword. This automatically creates getters
    Proposal[] public proposals;

    // Create a new ballot to choose one of `proposalNames`.
    // This is the function constructor, will be run only once, at the creation of the contract
    function Ballot() {
        chairperson = msg.sender; // msg.sender here is the contract creator (also it is an address)
    }

    // Add another proposal to our array
    function addProposal(string newProposal, string desc){
        // `Proposal({...})` creates a temporary
        // Proposal object and `proposals.push(...)`
        // appends it to the end of `proposals`.
        proposals.push(Proposal({
                name: newProposal,
                description: desc,
                voteCount: 0
            }));
    }



    // Remove a `voter` right to vote on this ballot.
    // May only be called by `chairperson`. --> BAD DEMOCRACY!
    function removeRightToVote(address voter) {
        if (msg.sender != chairperson) {
            // `throw` terminates and reverts all changes to
            // the state and to Ether balances. It is often
            // a good idea to use this if functions are
            // called incorrectly. But watch out, this
            // will also consume all provided gas.
            throw;
        }
        voters[voter].voted = true;
    }


    // Vote for the specified proposal
    function vote(uint proposal) {
        Voter sender = voters[msg.sender];
        if (sender.voted){
            throw;
        }

        sender.voted = true;
        sender.vote = proposal;

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += 1;
        // Send a message saying that we voted, can be picked up by a Dapp
        Voted(msg.sender,  proposals[proposal].voteCount);
    }

    // Computes the winning proposal taking all
    // previous votes into account.
    // Notice the keyword 'constant', it won't need gas to run
    // IF and (right now) ONLY IF it is called with web3 (for a Dapp)
    // The constant aspect is not implemented in the compiler yet
    // Note the internal modifier, this function can only be called by the contract
    function winningProposal() constant internal returns (uint winningProposal) {
        uint winningVoteCount = 0;
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposal = i;
            }
        }
        return winningProposal;
    }



    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() constant returns (string winnerName) {
        winnerName = proposals[winningProposal()].name;
    }

    function donateToCreator() payable {
        Donation(msg.sender, chairperson, msg.value);
        balance += msg.value;
    }

    // Creator claims all the donations to the contract
    function creatorPayday() isCreator {
    // This is considered the SAFE method
      uint toSend = balance;
      balance = 0;
      if(!msg.sender.send(toSend)){
        throw;
      }

      // unsafe way of doing it (DAO hack)
      // uint toSend = balance;
      // if(!msg.sender.send(toSend)){ Rememeber that any transaction can go to any address (including contract addresses)
      //   throw; // these can execute code and call this function again and again, before balance = 0; finishes
      // }
      // balance = 0; Not a great example here, as only the owner will be the one able to get his money


    }

    function destroy() isCreator {
        // It is important to have a selfdestruct option in Ethereum. Not only will all the
        // Money be send to the address passed in, but also it will free up some memory in
        // the blockchain, and you are subsidized for that, be a good citizen!
      selfdestruct(msg.sender);
    }
}

// forked and adapted from https://solidity.readthedocs.io/en/latest/solidity-by-example.html