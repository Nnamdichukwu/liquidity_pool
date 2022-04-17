//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract liquidity{
    struct PoolInfo{
        string desc;
        uint amount;
        uint maxPoolSize;
        address creator;
        uint pool_duration;
        uint  start_date;
        uint locktime;
        mapping(address => bool) creator_count;
       
    }
    struct Pool_liquidity{
        mapping(address => uint) contributors;
        uint totalLiquidity;
        uint totalContributors;
        mapping(address => bool) paid_out;
        //mapping(adddress => uint) locktime;
        uint total_withdrawals;
    }
    address public owner;
    uint private withdrawal_counter;
    mapping(address => uint) public lps;
    mapping (address => PoolInfo) public pool_info;
    mapping (address => Pool_liquidity) public pool_liquidity;
    uint public start = block.timestamp;
    modifier requireOwner (){
        require(msg.sender == owner);
        _;
    }
    constructor(){
        owner = msg.sender;
    }
    //event PoolCreation( string indexed owner, string description);
   // event Contribution(string )
    function createPool(string memory _desc, uint _amount,uint _duration, uint _size, uint _locktime)public requireOwner{
        require(!pool_info[owner].creator_count[owner]);
        pool_info[msg.sender].creator = msg.sender;
        pool_info[msg.sender].desc = _desc;
        pool_info[msg.sender].amount = _amount * 10 **18 ;
        pool_info[msg.sender].pool_duration = block.timestamp + _duration ; 
        pool_info[msg.sender].maxPoolSize = _size;
        pool_info[msg.sender].start_date = block.timestamp ;
        pool_info[msg.sender].locktime = block.timestamp + _locktime;
    }
    function getTime() public view returns(uint){
       return pool_info[msg.sender].start_date ;
        }
    function joinPool(address _to) public payable {
        require (_to == owner);
        require (msg.value * 10**18 >= pool_info[owner].amount, "too small");
        require( block.timestamp <  pool_info[owner].pool_duration , "time has elapsed");
        require (msg.value * 10**18 >= pool_info[owner].amount, "too small");
        require(pool_liquidity[owner].totalContributors < pool_info[owner].maxPoolSize);
        uint balance = msg.value- pool_info[_to].amount   ;
        lps[msg.sender] = 1;
        uint amount = msg.value - balance; 
        pool_liquidity[_to].totalLiquidity += amount;
        pool_liquidity[_to].contributors[msg.sender] += amount;
        pool_liquidity[_to].totalContributors++;
        
       if(msg.value > pool_info[_to].amount){
        payable(address(msg.sender)).transfer(balance);   
       
        payable(address(owner)).transfer(amount);
         
            
       }
      else{
      
          payable(address(owner)).transfer(msg.value);
           
      } 
    }
    function rejoinPool(address _to) public payable{
         require (_to == owner);
        require(lps[msg.sender] >= 1);
       require (msg.value * 10**18 >= pool_info[owner].amount, "too small");
       require(block.timestamp > withdrawal_counter);
        uint balance = msg.value- pool_info[_to].amount   ;
        lps[msg.sender] = 1;
        uint amount = msg.value - balance; 
        pool_liquidity[_to].totalLiquidity += amount;
        pool_liquidity[_to].contributors[msg.sender] += amount;
        pool_liquidity[_to].totalContributors++;
        
       if(msg.value > pool_info[_to].amount){
        payable(address(msg.sender)).transfer(balance);   
       
        payable(address(owner)).transfer(amount);
         
            
       }
      else{
      
          payable(address(owner)).transfer(msg.value);
           
      } 
    }
   function withdrawal(address _to, address from) public payable {
       require( block.timestamp >  pool_info[owner].locktime);
       require(!pool_liquidity[from].paid_out[msg.sender]);
       require( pool_liquidity[_to].contributors[msg.sender]> 0);
       uint amount = pool_liquidity[from].totalLiquidity;
       pool_liquidity[from].paid_out[msg.sender] = true;
       payable(address(_to)).transfer(amount); 
       withdrawal_counter = block.timestamp;
   }
}
