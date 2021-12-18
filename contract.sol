// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";


contract Allowance is Ownable{
    using SafeMath for uint;
    event AllowanceStatus(address sender, address receiver, uint oldamount, uint currentamount);
    mapping (address => uint) public allowanceForAddress;
    
    function isOwner() public view virtual returns (bool) {
        return msg.sender == owner();
    }
    
    
    function addAllownace(address _who, uint _amount) public onlyOwner{
        emit AllowanceStatus(msg.sender, _who, allowanceForAddress[_who], allowanceForAddress[_who] + _amount);
        allowanceForAddress[_who] = _amount;
        
    }
    
    modifier ownerOrAllowed(uint _amount){
        require(isOwner() || allowanceForAddress[msg.sender] >= _amount, 'You are not allowed!');
        _;
    }
    function reduceAllowance(address _who, uint _amount) internal {
        emit AllowanceStatus(msg.sender, _who, allowanceForAddress[_who], allowanceForAddress[_who].sub( _amount));
        allowanceForAddress[_who].sub(_amount);
    }
    function getCurrentAllowance() public view returns(uint){
        return allowanceForAddress[msg.sender];
    }
    
}

contract SmartWallet is Allowance{
    event ReceivedStatus (address sender, uint _amount);
    event SendStatus(address receiver, uint _amount);
    function renounceOwnership() override view public onlyOwner{
        revert('Cannot Renounce! Illegal!!!');
    }

    receive() external payable{
        emit ReceivedStatus(msg.sender, msg.value);
    }
    
    function sendMoneyToContract(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
        require(_amount <= address(this).balance, 'Not Enough Balance!');
        if (!isOwner()){
            reduceAllowance(msg.sender, _amount);
        }
        emit SendStatus( _to, _amount);
        _to.transfer(_amount);
        
    }
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}