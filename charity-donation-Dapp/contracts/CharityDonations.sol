// the regular donation contract

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./contributorNFT.sol";

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
        string[] updates;
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
    mapping(address => bool) public admins;
    mapping(address => bool) public signers;
    mapping(uint => mapping(address => bool)) approvedSignatures;

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
        uint numberOfDonors
    );
    event TransactionCreated(
        uint txId, 
        address recipient, 
        uint amount
    );
    event TransactionApproved(
        uint txId, 
        address signer
    );
    event TransactionExecuted(
        uint txId, 
        address recipient, 
        uint amount
    );
    event TopContributorsRewarded(
        uint campaignId, 
        address[] topContributors
    );


    //modifiers, they are special functions that can modify the behavior of other functions, we have inbuit and custom
    modifier onlyCreator(uint _campaignId) {
        require (msg.sender == campaigns[_campaignId].owner, "Not the campaign creator");
            _;
    }
    

    modifier onlyAdmin() {
        require(msg.sender == admins, "Not the admin");
        _;
    }

    modifier onlySigner() {
        require(msg.sender == signers, "Not the signer");
        _;
    }
    modifier validCampaign(uint _id) {
        require(_id < campaigns.length, "Campaign does not exist");
        _;
    }


    //set a constructor thar runs when the contract is deployed
    constructor(address[] memory _admin, address[] memory _signer, uint _requiredSignatures, address _ContributorNFTAddress){
        require(_requiredSignatures > 0, "Required signatures should be greater than 0");
        require (signers.length == _requiredSignatures, "Number of signers should be equal to required signatures");

        for(uint i = 0; i < _admin.length; i++){
            admins[_admin[i]] = true;
        }

        for(uint i = 0; i < _signer.length; i++){
            signers[_signer[i]] = true;
        }

        contractOwner = msg.sender;
        requiredSignatures = _requiredSignatures;
        contributorNFT = contributorNFT(_ContributorNFTAddress);

            
    }
    
    //My functions
    // Create a new campaign
    function createCampaign( 
        uint id,
        string memory _title,
        string memory _description,
        uint _goal,
        uint _deadline) external onlyAdmin { require(_goal > 0, "Goal should be greater than 0");
        

        campaigns[campaignCount] = Campaign({
            title: _title,
            description: _description,
            deadline: _deadline,
            goal: 0,
            creator: msg.sender,
            isCompleted: false 
        });

        emit CampaignCreated(_title, _description, campaignCount, _goal, _deadline, msg.sender);
        campaignCount++;
    }
    //Function to update the status of the camaign

    function updateCampaignStatus(uint _campaignId, bool _isCompleted) external onlyAdmin {
        Campaign storage campaign = campaigns[_campaignId];

        //check if the campaign exits
        require(campaign.goal > 0, "Campaign does not exist");

        //we check if the campaign is already completed
        require(!campaign.isCompleted, "Campaign is already completed");

        //check if campaign has reached it's target amount
        require(campaign.amountRaised >= campaign.goal, "Campaign has not reached it's target amount");

        //if ye mark the campaign as completed
        campaign.isCompleted = true;

        emit CampaignCompleted(_campaignId, campaign.amountRaised, donors[_campaignId].length);
    }


    //Function to donate to a campaign
    function donateToCampaign(uint _campaignId) external payable {
        require(msg.value >= MIN_DONATION, "Minimum donation amount is 0.01 ether");

       Campaign storage campaign = campaigns[_campaignId];
       //check if the campaign has ended or it it is still within the limits

       require(
        block.timestamp < campaigns[_campaignId].deadline, "Campaign has already ended"

       );
       require(!campaign.isCompleted, "Campaign is already completed");

       //check to make sure the amount is not exceeding the goal
       require(
        campaigns[_campaignId].amountRaised + msg.value <= campaigns[_campaignId].goal, " Donations will exceed the goal"
       );

       //upon successfull donation, we add the donor to the donors array
       if (!hasDonated[_campaignId][msg.sender]){
           hasDonated[_campaignId][msg.sender] = true;
           campaigns[_campaignId].numberOfDonors +=1;
       }

       //record the donation details
       campaignDonors[_campaignId].push(
        Donor({
            donorAddress: msg.sender, amount: msg.value
        })
       );

        //updater the total amount raised for the campaign
       campaigns[_campaignId].amountRaised += msg.value;

       //if target has reached mark the campaign as completed
       if (
        campaigns[_campaignId].amountRaised >= campaigns[_campaignId].goal
       ){
        campaigns[_campaignId].isCompleted = true;
        emit CampaignCompleted(_campaignId, campaigns[_campaignId].amountRaised, campaigns[_campaignId].numberOfDonors);
       }


       // NOW WE EMIT THE DONATION EVENT
       emit DonationReceived(_campaignId, msg.value, msg.sender, campaigns[_campaignId].amountRaised);
    }
    function getTopContributors(uint _campaignId) public view returns (address[] memory) {
        Donation[] memory campaignDonations = donations[_campaignId];
        address[] memory topContributorsList = new address[](3);
        uint[] memory topAmounts = new uint[](3);

        for (uint i = 0; i < campaignDonations.length; i++) {
            address donor = campaignDonations[i].donor;
            uint amount = campaignDonations[i].amount;

            if (amount > topAmounts[0]) {
                topAmounts[2] = topAmounts[1];
                topContributorsList[2] = topContributorsList[1];
                topAmounts[1] = topAmounts[0];
                topContributorsList[1] = topContributorsList[0];
                topAmounts[0] = amount;
                topContributorsList[0] = donor;
            } else if (amount > topAmounts[1]) {
                topAmounts[2] = topAmounts[1];
                topContributorsList[2] = topContributorsList[1];
                topAmounts[1] = amount;
                topContributorsList[1] = donor;
            } else if (amount > topAmounts[2]) {
                topAmounts[2] = amount;
                topContributorsList[2] = donor;
            }
        }

        return topContributorsList;
    }


    // Reward the top 3 contributors with NFTs
    //function rewardTopContributors(uint _campaignId) external onlyAdmin validCampaign(_campaignId) {
       // address[] memory topContributors = getTopContributors(_campaignId);

        //for (uint i = 0; i < topContributors.length; i++) {
          //  if (topContributors[i] != address(0)) {
             //   string memory tokenURI = string(abi.encodePacked("https://example.com/metadata/", uint2str(i + 1)));

             //   contributorNFT.mintNFT(topContributors[i], tokenURI);
          //  }
       // }

     //   emit TopContributorsRewarded(_campaignId, topContributors);
    //}

    // this allows Withdrawal of funds  with multisignature approval from the signers

    function withdrawFunds(uint _campaignId, uint _amount, address payable _recipient) external onlySigner validCampaign(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(campaign.totalDonated >= _amount, "Insufficient funds");

        transactionCount++;
        transactions[transactionCount] = Transaction({
            amount: _amount,
            recipient: _recipient,
            executed: false,
            approvals: 0
        });

        emit TransactionCreated(transactionCount, _recipient, _amount);
    }
}
