pragma solidity ^0.4.25;
        
        /*      Welcome to my submission for EthSF!
            This is a Payroll System built for ether miners.
                        I hope you enjoy.                      */
    
            // # This contract should be initiated by # //
            // #        oInterface.sol                # //
            //github: https://github.com/DanteAlabastro
            //remix: https://remix.ethereum.org/#version=soljson-v0.4.25+commit.59dbf8f1.js&optimize=true&gist=6cbbc20d8e304487ebb78438a3d8895e    
contract payroll{
    
    /* Deposit */
    function deposit() payable public PayPeriod{
        redistribute();
        }
    
    /* Variables */
    address owner = msg.sender;

    uint blockweeks = 1209600; // 14 days in 14 second blocktime
    uint creation = block.number;
    uint public lastPayday = block.number;
    uint public nextPayday = lastPayday + blockweeks;
    bool payPeriodToggle = true;
    
    uint Balance;
    uint AvailableBalance;
    uint ReservedBalance;
    uint GasReserve;
    
    uint256 EmployeeCount;
    uint256 ID = 1;
    
    /* Event */
    event broadcast(string);
        
    /* Modifiers */

    modifier Owned(){
        require (msg.sender == owner);
        _;
    }
    
        // Check for passing of 2 weeks.
    modifier PayPeriod(){
        if (lastPayday + blockweeks <= block.number){
        lastPayday += blockweeks;
        Distribute();
        _;
        }
        _;
    }

        // Biweekly payments with 3 day window is toggleable in preference of...
        // manual distribution.
    modifier PayDay() {
        if (payPeriodToggle == true){
            require(lastPayday <= block.number);
            require(block.number <= lastPayday + 259200);
             _;
             }
             _;
    }
    
    /* Mapping */
        // Employee info.
    mapping (uint256 => string) _Name;          
    mapping (uint256 => uint256) _IDnumber;
    mapping (uint256 => address) _Address;
    mapping (uint256 => uint256) _Balance;
    mapping (uint256 => bool) _Lock;
        //Reverse lookup
    mapping (address => uint256) IDbyAddress;
    
    /* Functions */
    
        // Update Balance + AvailableBalance. Check for PayPeriod.
    function redistribute() internal {
        Balance = address(this).balance;
        if(Balance > ReservedBalance + GasReserve){
        AvailableBalance = Balance - (ReservedBalance + GasReserve);
        }
    } 
    
        // Distribute Funds
    function Distribute() internal PayDay{
        require(EmployeeCount > 0);
        redistribute();
        require(AvailableBalance > 0);
        uint Payout = AvailableBalance / EmployeeCount;
        for(uint i=1; i <= ID -1; i++) {
            if(_IDnumber[i] >= 1 ){
            _Balance[i] += Payout ;
            }
        }
        ReservedBalance += AvailableBalance;
        AvailableBalance = 0;
    }
}
