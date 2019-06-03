

pragma solidity ^0.5.4;

import "./library/SafeMath.sol";
import "./library/Ownable.sol";

contract SimpleToken is Ownable {

    using SafeMath for uint256;

    /* ERC20 INTERFACE */
    string public name = "TOKEN NAME";
    string public symbol = "SYMBOL";
    uint8 public decimals = 18;
    uint256 public totalSupply = 0;

    mapping (address => mapping (address => uint256)) internal allowed;
    mapping(address => uint256) balances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);


    // Not implemented
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {}
    function approve(address _spender, uint256 _value) public returns (bool) {}
    function allowance(address _owner, address _spender) public view returns (uint256) {}

    function balanceOf(address _owner) public view returns (uint256 balance) { return balances[_owner];}

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /* END OF ERC20 INTERFACE */

    // Default max supply is 1000
    uint256 maxSupply = 1000;

    // Minting function, adds tokens to our total supply
    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        // Add to the total supply
        totalSupply = totalSupply.add(_amount);
        // Ensure it is less than the max supply
        require(totalSupply < maxSupply);
        // Add to balance
        balances[_to] = balances[_to].add(_amount);
        // Emit events
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

}