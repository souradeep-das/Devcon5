pragma solidity ^0.5.2;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

contract Fallback  {
  
  address payable owner;
  using SafeMath for uint256;
  mapping(address => uint) public contributions;

  constructor() public {
    contributions[msg.sender] = 1000 * (1 ether);
    owner = msg.sender;
  }

  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] = contributions[msg.sender].add(msg.value);
    if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
  }

  function withdraw() public {
    require(owner == msg.sender);
    owner.transfer(address(this).balance);
  }
  
   function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function() payable external{
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
}