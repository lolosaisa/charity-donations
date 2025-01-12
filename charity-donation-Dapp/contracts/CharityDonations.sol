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

    struct Donor {
        address donor;
        uint amount;
    }

    struct Donations {
        uint campaignId;
        uint amount;
        address donor;
    }

    //storage - mappings and arrays
    mapping(uint => Campaign) public campaigns;
    mapping(uint => Donor[]) public donors;
    mapping(address => Donations[]) public donations;
    mapping(uint => address[]) public topContributors;
    mapping(uint256 => mapping(address => bool)) public hasDonated;

    //events
    event CampaignCreated(
        string title,
        string description,
        uint id,
        uint goal,
        uint deadline,
        address owner
    )
        

}
