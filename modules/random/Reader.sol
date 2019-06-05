pragma solidity 0.5.4;

contract Reader {
    string public secret = "Hello there, I'm a secret";

    function whatIsTheAnswerOfLife() external pure returns(uint256) {
        return 42;
    }

    function echo(string calldata sent) external pure returns(string memory) {
        return sent;
    }

    function whatIsThis(string calldata sent, uint256 amount) external pure returns(string memory, uint256) {
        return (sent, amount);
    }


}