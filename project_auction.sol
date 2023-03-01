pragma solidity ^0.8.4;

contract auction {
    address payable public beneficiary;
    uint public auction_end_time;
    address public heighest_bidder;
    uint public heighest_bid;
    bool ended;
    mapping (address => uint) pending_returns;

    event heighest_bid_inc(address bidder, uint amount);
    event auction_ended(address winner, uint amount);

    constructor(uint bidding_time,address payable benef){
        beneficiary=benef;
        auction_end_time=block.timestamp+bidding_time;
    }

    function bid() public payable {

        if (block.timestamp>auction_end_time) revert("auction has ended");

        if (msg.value<=heighest_bid) revert("bid is not high enough");

        if (heighest_bid!=0) {
            pending_returns[heighest_bidder]+=heighest_bid;
        }

        heighest_bidder=msg.sender;
        heighest_bid=msg.value;
        emit heighest_bid_inc(msg.sender,msg.value);
    }

    function withdraw() public payable returns(bool)  {
        uint amount=pending_returns[msg.sender];
        if(amount>0){
            pending_returns[msg.sender]=0;
        }

        if(!payable(msg.sender).send(amount)){
            pending_returns[msg.sender]=amount;
        }
        return true;
    }

    function auction_end() public {
        if(block.timestamp<auction_end_time) revert("auction has not ended yet");

        if(ended) revert("the auction is already over");
        ended=true;
        emit auction_ended(heighest_bidder,heighest_bid);
        beneficiary.transfer(heighest_bid);
    }

}