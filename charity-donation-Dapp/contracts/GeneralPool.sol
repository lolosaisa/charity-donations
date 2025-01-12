//General donations smart contract
 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GeneralPool {
    address public admin;
    uint public totalFunds;

    event FundsReceived(address donor, uint amount);
    event FundsDistributed(address recipient, uint amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function donateToPool() external payable {
        totalFunds += msg.value;
        emit FundsReceived(msg.sender, msg.value);
    }

    function distributeFunds(address payable _recipient, uint _amount) external onlyAdmin {
        require(_amount <= totalFunds, "Insufficient funds");

        _recipient.transfer(_amount);
        totalFunds -= _amount;

        emit FundsDistributed(_recipient, _amount);
    }
}

