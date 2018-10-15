pragma solidity ^0.4.25;
        
        /*      Welcome to my submission for EthSF!
            This is a Payroll System built for ether miners.
                        I hope you enjoy.                      */
        
                // # Now collected in one contract! # //
            
    //github: https://github.com/DanteAlabastro
    //remix: https://remix.ethereum.org/#version=soljson-v0.4.25+commit.59dbf8f1.js&optimize=true&gist=6cbbc20d8e304487ebb78438a3d8895e    

// I transitioned to SafeMath! Let's hope nothing is broken...
// import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

    // Local import for testing.

contract payroll{
    library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
  
}
    using SafeMath for uint256;
    /* a + b becomes a.add(b)
    |  a - b becomes a.sub(b)
    |  a * b becomes a.mul(b)
    |  a / b becomes a.div(b)
    */
    
        // Test SafeMath import
    function Add(uint256 a, uint256 b) public pure returns (uint256){
      a = a.add(b);
      return a;
    }
    
    /* Deposit */
    function deposit() payable public PayPeriod{
        redistribute();
        }
  
    /* Variables */
    address private owner = msg.sender;

    uint blockweeks = 1209600; // 14 days in 14 second blocktime
    uint creation = block.number;
    uint public lastPayday = block.number;
    uint public nextPayday = lastPayday.add(blockweeks);
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
        require (msg.sender == owner, "Administrative access required.");
        _;
    }
    
        // Check for passing of 2 weeks.
    modifier PayPeriod(){
        if (lastPayday.add(blockweeks) <= block.number){
        lastPayday = lastPayday.add(blockweeks);
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
            require(block.number <= lastPayday.add(259200));
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
    
    /* Core Functions */
    
        // Update Balance + AvailableBalance. Check for PayPeriod.
    function redistribute() internal {
        Balance = address(this).balance;
        if(Balance > ReservedBalance.add(GasReserve)){
        AvailableBalance = Balance.sub((ReservedBalance.add(GasReserve)));
        }
    } 
    
        // Distribute Funds
    function Distribute() internal PayDay{
        require(EmployeeCount > 0, "There are no employees in the system.");
        redistribute();
        require(AvailableBalance > 0, "There are no funds available.");
        uint Payout = AvailableBalance.div(EmployeeCount);
        ReservedBalance = ReservedBalance.add(AvailableBalance);
        AvailableBalance = 0;
        for(uint i=1; i <= ID -1; i++) {
            if(_IDnumber[i] >= 1 ){
            _Balance[i] = _Balance[i].add(Payout) ;
            }
        }
    }
    
    /* Employee Funcitons */
    
    function IsitPayday() public view returns (bool){
        require(payPeriodToggle == true, "This feature has been turned off.");
        if ( lastPayday <= block.number && block.number <= lastPayday + 259200){
            return true;
        }
            return false;
    }

    function GetEmployeeInfo() public view returns(string, uint256, address, uint256, bool){
        require(_Address[IDbyAddress[msg.sender]] == msg.sender, "Your account is not listed in the database.");
        uint256 EmployeeID = IDbyAddress[msg.sender];
        return(_Name[EmployeeID], EmployeeID, _Address[EmployeeID], _Balance[EmployeeID], _Lock[EmployeeID]);
    }

    
    function Withdrawl(uint256 EmployeeID) public PayDay {
        require(_Address[EmployeeID] == msg.sender, "The ID you provided does not match you address.");
        require(_Lock[EmployeeID] == false, "This account has been locked.");
        msg.sender.transfer(_Balance[EmployeeID]);
        ReservedBalance = ReservedBalance.sub(_Balance[EmployeeID]);
        _Balance[EmployeeID] = 0;
    }
    
    /* Admin Functions */
        // Onboarding and Offboarding + Employee lookup and management.
    
        //Onboard    
    function onboard(string Name, address Address) public Owned {
        _Name[ID] = Name;
        _IDnumber[ID] = ID;
        _Address[ID] = Address;
        _Balance[ID] = 0;
        _Lock[ID] = false;
        IDbyAddress[Address] = ID;
        EmployeeCount++;
        ID++;
        
        GasReserve = EmployeeCount.mul(1e9 wei);

        emit broadcast(Name);
        
    }
        //ID lookup
    function getbyID(uint256 EmployeeID) public view Owned returns(string, address, uint256, bool){
        return(_Name[EmployeeID], _Address[EmployeeID], _Balance[EmployeeID], _Lock[EmployeeID]);
    }
        //Account Lock
    function EmployeeLock(uint256 EmployeeID, bool Toggle) public Owned {
        _Lock[EmployeeID] = Toggle;
    }
        //Address change. Requires _Lock = True.
    function changeAddress(uint256 EmployeeID, address Address) public Owned{
        require(_Lock[EmployeeID] == true, "This account must be locked in order to make changes.");
        _Address[EmployeeID] = Address;
    }
        //Offboard. Requires _Lock = True.
    function DeleteUser(uint256 EmployeeID) public Owned{
        require(EmployeeCount > 0);
        require(_Lock[EmployeeID] == true, "This account must be locked in order to make changes.");
        AvailableBalance = AvailableBalance.add(_Balance[EmployeeID]);
        ReservedBalance = ReservedBalance.sub(_Balance[EmployeeID]);
        IDbyAddress[_Address[EmployeeID]] = 0;
        _Name[EmployeeID] = '';
        _IDnumber[EmployeeID] = 0;
        _Address[EmployeeID] = 0;
        _Balance[EmployeeID] = 0;
        _Lock[EmployeeID] = true;
        EmployeeCount--;
        
        GasReserve = EmployeeCount.mul(1e9 wei);
    }
    
        // The 2 week payperiod restriction can be toggled here.
    function requirePayperiod(bool Toggle) public Owned{
        payPeriodToggle = Toggle;
    }
    
        // Manual distribute. Requires payPeriodToggle = False if not PayPeriod. See requirePayperiod.
    function manualDistribute() public PayDay Owned{
        Distribute();
    }
}