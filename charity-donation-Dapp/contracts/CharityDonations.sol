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
    uint public campaignCount;

    mapping(uint => Campaign) public campaigns;
    mapping(uint => Donor[]) public donors;
    mapping(address => Donations[]) public donations;
    mapping(uint => address[]) public topContributors;
    mapping(uint256 => mapping(address => bool)) public hasDonated;

// setting a minimum donation amount
    uint public constant MIN_DONATION = 0.01 ether;


    //events
    event CampaignCreated(
        string title,
        string description,
        uint id,
        uint goal,
        uint deadline,
        address owner
    );
    event DonationReceived(
        uint campaignId,
        uint amount,
        address donor,
        uint totalAmountRaised
    );
    event CampaignCompleted(
        uint campaignId,
        uint totalAmountRaised,
        uint numberOfDonors,
    )

    

        

}
