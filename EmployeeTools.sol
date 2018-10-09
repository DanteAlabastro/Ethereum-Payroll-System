pragma solidity ^0.4.25;

import 'gist/Distribution.sol';

contract EmployeeTools is payroll {
    
    function IsitPayday() public view returns (bool){
        require(payPeriodToggle == true);
        if ( lastPayday <= block.number && block.number <= lastPayday + 259200){
            return true;
        }
            return false;
    }

    function GetEmployeeInfo() public view returns(string, uint256, address, uint256, bool){
        require(_Address[IDbyAddress[msg.sender]] == msg.sender);
        uint256 EmployeeID = IDbyAddress[msg.sender];
        return(_Name[EmployeeID], EmployeeID, _Address[EmployeeID], _Balance[EmployeeID], _Lock[EmployeeID]);
    }

    
    function Withdrawl(uint256 EmployeeID) public PayDay {
        require(_Address[EmployeeID] == msg.sender);
        require(_Lock[EmployeeID] == false);
        msg.sender.transfer(_Balance[EmployeeID]);
        ReservedBalance -= _Balance[EmployeeID];
        _Balance[EmployeeID] = 0;
    }
}