// Smart Contract 3: NFT Rewards Contract
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ContributorNFT is ERC721URIStorage {
    address public contractOwner;
    uint256 public constant TOP_CONTRIBUTOR_BADGE = 0; 
    uint256 public tokenCounter;  // Counter for unique token IDs
    mapping(address => uint256) public contributorTokens;  // Mapping to track who has been issued an NFT
    string public baseURI;  // Base URI for token metadata

    // Event to log when an NFT is minted
    event NFTMinted(address indexed contributor, uint256 tokenId);

    constructor(string memory _baseURI) ERC721("ContributorNFT", "CNFT") {
        baseURI = _baseURI;
        tokenCounter = 0;
        contractOwner = msg.sender;
    }
     modifier onlyOwner {
        require(contractOwner == msg.sender, "Not  the contract owner");
        _;
    }

    // Function to mint an NFT for a contributor
    function mintNFT(address contributor, string memory tokenURI) public onlyOwner {
        require(contributor != address(0), "Invalid address");

        // Increment the counter for the next token ID
        uint256 tokenId = tokenCounter;
        tokenCounter++;

        // Mint the NFT to the contributor
        _safeMint(contributor, tokenId);
        _setTokenURI(tokenId, tokenURI);
        contributorTokens[contributor] = tokenId;

        
        emit NFTMinted(contributor, tokenId);
    }

    //  Function to retrieve the base URI for metadata
    function getBaseURI() public view returns (string memory) {
        return baseURI;
    }

    // Function to update the base URI if needed (for owner only)
    function setBaseURI(string memory _newBaseURI) public onlyOwner  {
        baseURI = _newBaseURI;
    }
}