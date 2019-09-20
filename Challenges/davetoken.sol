pragma solidity ^0.5.2;

contract DaveToken {
    mapping(address => uint) balances;
    
    function buyToken() payable public {
        balances[msg.sender]+=msg.value / 1 ether;
    }
    
    function sendToken(address to,uint amount) public {
        require(balances[msg.sender] - amount >=0);
        balances[msg.sender] -= amount;
        balances[to]+=amount;
    } 
    
    function balanceOf(address acc)public view returns(uint) {
        return balances[acc];
    }
}
