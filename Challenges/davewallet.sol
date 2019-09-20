pragma solidity ^0.5.2;

contract DaveWallet {
    Wallet[] public wallets;
        
    struct Wallet {
      address owner;
      uint amount;
    }
    
    function addMoney() public payable {
      wallets.push(Wallet({
        owner: msg.sender,
        amount: msg.value
      }));
    }
    
    function withdraw() public {
      for (uint i; i<wallets.length; i++) {
        if (wallets[i].owner==msg.sender && wallets[i].amount!=0) {
          msg.sender.transfer(wallets[i].amount);
            wallets[i].amount=0;
        }
      }
        
    }
}

