// the regular donation contract

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Donation {
    struct Campaign {
        string title;
        string description;
        uint id;
        uint goal;
        uint deadline;
        uint amountRaised;
        address owner;
        bool isCompleted;
    }
}
