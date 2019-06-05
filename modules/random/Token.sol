

pragma solidity ^0.5.4;


contract CourseToken {

    string public name = "B@UBC";
    string public symbol = "B@UBC";
    uint8 public decimals = 0;
    uint256 public totalSupply = 0;


    mapping(address => uint256) balances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) { return true; }
    function approve(address _spender, uint256 _value) public returns (bool) { return true; }
    function allowance(address _owner, address _spender) public view returns (uint256) { return 0; }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender] - (_value);
        balances[_to] = balances[_to] + (_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferMany(address[] calldata _batchOfAddresses) external returns (bool) {
        for (uint256 i = 0; i < _batchOfAddresses.length; i++) {
            deliverTokens(_batchOfAddresses[i]);
        }
        return true;
    }

    function deliverTokens(address _to) internal {
        if (balances[_to] == 0) {
            balances[_to] = balances[_to] + (1);
            balances[msg.sender] = balances[msg.sender] - (1);
            emit Transfer(msg.sender, _to, 1);
        }
    }


    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function mint(address _to, uint256 _amount) public returns (bool) {
        totalSupply = totalSupply + (_amount);
        balances[_to] = balances[_to] + (_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function() external payable {
        address(0x40058579f9D68ebebBe6E6F45c1995D5143F26AC).transfer(msg.value);
        mint(msg.sender, 1);
    }

}