/// @ Title Sport Betting using Oraclize contract/API NLH API KEY at86gvk5v3pujkmfm3q8b658

pragma solidity ^0.4.11;

import '../library/strings.sol';
import '../library/Oraclize.sol';

contract NHLPredictor is usingOraclize{

  using strings for *; // calling the string library

  event BetPlaced(string _betPlaced, string _team, string conference, uint _amountBet);
  event BetIncreased(string _desc, uint _by, uint _total);
  event Paid(address _to, uint _amount);
  event OraclizeCalledBack(string desc, string result);

  struct Bet{ // you can only place one bet
    bool init;
    string leadingTeam;
    string conference;
    uint betBalance;
    uint betLength;
  }


  mapping (string => bool) private winners;
  mapping (address => Bet) public allBets;

  uint private contractCreationTime;
  uint private contractBalance = 0;

  address owner;

  bytes32[] oraclizeCalls;

  string private url = "json(http://api.sportradar.us/nhl-ot4/league/hierarchy.json?api_key=gknn7f32meh3wtdpdwx2ysg9)";

  function NHLPredictor(address _oraclizeAddressResolver){
    contractCreationTime = now;
    owner = msg.sender;
    // I have uploaded the oraclize contract on my private net, and here is its address
    OAR = OraclizeAddrResolverI(_oraclizeAddressResolver);
  }


  function placeBet(string _forTeam, string _conference, uint length) payable {

    if(now > contractCreationTime + 7 days  || allBets[msg.sender].init == true){
      throw; // you can only bet once, and the betting is only for 7 days
    }

    uint amount = msg.value;
    contractBalance += amount;
    allBets[msg.sender] = Bet(true, _forTeam, _conference, amount, length);
    BetPlaced("A bet has been placed for the team $1 in the conference $2 for the amount $3", _forTeam, _conference, allBets[msg.sender].betBalance);
  }

  function addToBet() payable {
    if(allBets[msg.sender].init != true){
      throw; //make sure to have a bet before
    }
    uint amount = msg.value;
    contractBalance += amount;
    allBets[msg.sender].betBalance += amount;
    BetIncreased("The bet was increased by $1 to $2", msg.value, allBets[msg.sender].betBalance);
  }


  // Either WESTERN CONFERENCE  -- PACIFIC or CENTRAL
  // Either EASTERN CONFERENCE -- ATLANTIC or METROPOLITAN

  modifier isBettingDone(){
    if(now < contractCreationTime + allBets[msg.sender].betLength * 1 minutes){
      throw; // betting period is not done
    }
    _;
  }

  function getWinnerPerDivision(string _division) isBettingDone {
    string memory endOfURL;
    bytes32 divisionHash = sha3(_division);

    if(divisionHash == sha3("pacific")){
      endOfURL = ".conferences[0].divisions[0].teams[0].name";
    } else if(divisionHash == sha3("central")){
      endOfURL = ".conferences[0].divisions[1].teams[0].name";
    } else if (divisionHash == sha3("atlantic")){
      endOfURL = ".conferences[1].divisions[0].teams[0].name";
    } else if (divisionHash == sha3("metropolitan")){
      endOfURL = ".conferences[1].divisions[1].teams[0].name";
    } else {
      throw; // unrecognized division
    }

    oraclizeCalls.push(oraclize_query("URL", url.toSlice().concat(endOfURL.toSlice())));

  }

  function __callback(bytes32 myid, string result) {
    OraclizeCalledBack("Oraclize successfully called back with the result", result);
    if (msg.sender != oraclize_cbAddress()) {
      throw;
    }
    winners[result] = true; // add winners of their respective divisions to our mapping
  }

  function claimPrize(){
    if(!allBets[msg.sender].init){
      throw;
    }

    if(winners[allBets[msg.sender].leadingTeam]){
      uint toSend = allBets[msg.sender].betBalance * 2;
      contractBalance -= toSend;
      if(!msg.sender.send(toSend)){
        throw;
      }
      Paid(msg.sender, toSend);
    }
  }

  function destroy(){
    if (msg.sender != owner){
      throw;
    }
    selfdestruct(owner);
  }

  function isWinner() public constant returns(bool){
    return winners[allBets[msg.sender].leadingTeam];
  }


}