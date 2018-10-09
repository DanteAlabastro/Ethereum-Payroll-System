pragma solidity ^0.4.25;

import 'gist/EmployeeTools.sol';

contract AdminTools is EmployeeTools{
    
             // Admin Tools //
             
        // Onboarding and Offboarding + Employee lookup and management.
    function onboard(string Name, address Address) public Owned {
        _Name[ID] = Name;
        _IDnumber[ID] = ID;
        _Address[ID] = Address;
        _Balance[ID] = 0;
        _Lock[ID] = false;
        IDbyAddress[Address] = ID;
        EmployeeCount++;
        ID++;
        
        GasReserve = EmployeeCount * 1e9 wei;

        emit broadcast(Name);
        
    }
    
    function getbyID(uint256 EmployeeID) public view Owned returns(string, address, uint256, bool){
        return(_Name[EmployeeID], _Address[EmployeeID], _Balance[EmployeeID], _Lock[EmployeeID]);
    }
    
    function EmployeeLock(uint256 EmployeeID, bool Toggle) public Owned {
        _Lock[EmployeeID] = Toggle;
    }
    
    function changeAddress(uint256 EmployeeID, address Address) public Owned{
        require(_Lock[EmployeeID] == true);
        _Address[EmployeeID] = Address;
    }
    
    function DeleteUser(uint256 EmployeeID) public Owned{
        require(EmployeeCount > 0);
        require(_Lock[EmployeeID] == true);
        AvailableBalance = AvailableBalance + _Balance[EmployeeID];
        ReservedBalance = ReservedBalance - _Balance[EmployeeID];
        IDbyAddress[_Address[EmployeeID]] = 0;
        _Name[EmployeeID] = '';
        _IDnumber[EmployeeID] = 0;
        _Address[EmployeeID] = 0;
        _Balance[EmployeeID] = 0;
        _Lock[EmployeeID] = true;
        EmployeeCount--;
        
        GasReserve = EmployeeCount * 1e9 wei;
    }
    
        // The 2 week payperiod restriction can be toggled here.
    function requirePayperiod(bool Toggle) public Owned{
        payPeriodToggle = Toggle;
    }
    
        // Manual distribute
    function manualDistribute() public Owned{
        Distribute();
    }
}