# Devcon 5 Auction
# Masked Reveal Auction

struct Data:
    hashval: bytes32
    sentval: wei_value
    bidval: wei_value
    hasbid: bool
    hasrevealed: bool
    refunded: bool
    winner: bool

owner: public(address)
ticketCount: public(int128)
minBid: public(uint256)  
winValue: public(wei_value)
addToData: public(map(address,Data))

bidOpenTime: public(timestamp)
bidEndTime: public(timestamp)
revealOpenTime: public(timestamp)
revealEndTime: public(timestamp)

@public
def __init__(_minBid: uint256, _bidTime: timedelta):
    self.minBid = _minBid
    self.owner = msg.sender
    self.ticketCount = 0
    self.bidOpenTime = block.timestamp
    self.bidEndTime = self.bidOpenTime + _bidTime
    
@public
@constant
def calculateHash(_bidval: wei_value,passw: bytes[100]) -> bytes32:
    return keccak256(concat(convert(_bidval,bytes32),passw))
    
@public
@payable
def bid(_hash: bytes32):
    assert block.timestamp >= self.bidOpenTime and block.timestamp<= self.bidEndTime,"Bidding Phase over"
    assert msg.value >= self.minBid,"Bid lesser than the minimum Bid amount"
    assert self.addToData[msg.sender].hasbid == False,"Bid Already placed"
    self.addToData[msg.sender]= Data({hashval:_hash,sentval: msg.value,bidval: 0, hasbid: True, hasrevealed: False, refunded: False, winner: False})

@public
def setWinningAmount(_amount: wei_value):
    assert msg.sender == self.owner,"Not Owner"
    self.winValue = _amount
    self.revealOpenTime = block.timestamp
    self.revealEndTime = self.revealOpenTime + 86400
    

@public
@payable
def reveal(_bidval: wei_value,passw: bytes[100]):
    assert block.timestamp >= self.revealOpenTime and block.timestamp <= self.revealEndTime,"Reveal Period not active"
    assert keccak256(concat(convert(_bidval,bytes32),passw)) == self.addToData[msg.sender].hashval,"Bid Value doesn't match!"
    assert self.addToData[msg.sender].sentval >= _bidval,"Fake Bid!"
    self.addToData[msg.sender].bidval = _bidval
    self.addToData[msg.sender].hasrevealed = True
    # Comment the rest part of this function to switch to the actual implementation of Devcon tickets
    # Simplified alternate way to select the first 50 revealers
    if _bidval >= self.winValue:
        assert self.ticketCount <= 50,"All tickets revealed - zero left"
        assert self.addToData[msg.sender].winner == False
        self.addToData[msg.sender].winner = True
        self.ticketCount += 1
        
        
# The actual way of selecting the top 50 addresses for 50 Devcon tickets
# Uncomment this portion for the actual implementation
    
#@public
#def selectWinners(winners: address[50]):
#   assert msg.sender == self.owner,"Only owner can access"
#   for i in range(50):
#       self.addToData[winners[i]].winner = True
      
        
@public
def withdraw():
    assert self.addToData[msg.sender].hasrevealed == True, "Early Withdraw!"
    assert self.addToData[msg.sender].refunded == False, "Already Refunded!"
    if self.addToData[msg.sender].winner == True:
        self.addToData[msg.sender].refunded = True
        send(msg.sender,self.addToData[msg.sender].sentval-self.addToData[msg.sender].bidval)
    else:  
        self.addToData[msg.sender].refunded = True
        send(msg.sender,self.addToData[msg.sender].sentval)
    
@public
@constant
def contractBalance() -> wei_value:
    return self.balance
    
@public
def owner_withdraw():
    assert msg.sender == self.owner,"Only Owner can access this"
    send(self.owner,self.balance)


    
    
        
