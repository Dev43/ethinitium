

pragma solidity ^0.4.15;

import './SafeMath.sol';
import './Ownable.sol';

contract CourseToken is Ownable {

    using SafeMath for uint256;

    string public name = "Blockchain Summit";
    string public symbol = "B@UBC";
    uint8 public decimals = 0;
    uint256 public totalSupply = 0;

    mapping (address => mapping (address => uint256)) internal allowed;
    mapping(address => uint256) balances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) { return true; }
    function approve(address _spender, uint256 _value) public returns (bool) { return true; }
    function allowance(address _owner, address _spender) public constant returns (uint256) { return 0; }

    function transfer(address _to, uint256 _value) public returns (bool) {
      require(_to != address(0));
      require(_value <= balances[msg.sender]);
      require(msg.sender == owner);

      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
    }

    function transferMany(address[] _batchOfAddresses) external onlyOwner returns (bool) {
      for (uint256 i = 0; i < _batchOfAddresses.length; i++) {
          deliverTokens(_batchOfAddresses[i]);
      }
      return true;
    }

    function deliverTokens(address _to) internal {
      if (balances[_to] == 0) {
        balances[_to] = balances[_to].add(1);
        balances[msg.sender] = balances[msg.sender].sub(1);
        Transfer(msg.sender, _to, 1);
      }
    }


    function balanceOf(address _owner) public constant returns (uint256 balance) {
      return balances[_owner];
    }

    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
      totalSupply = totalSupply.add(_amount);
      balances[_to] = balances[_to].add(_amount);
      Mint(_to, _amount);
      Transfer(address(0), _to, _amount);
      return true;
    }

}