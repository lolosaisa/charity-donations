// Smart Contract 3: NFT Rewards Contract
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ContributorNFT is ERC721URIStorage {
    address public contractOwner;
    uint256 public constant TOP_CONTRIBUTOR_BADGE = 0; 
    uint256 public tokenCounter;  
    mapping(address => uint256) public contributorTokens;  // Mapping to store the token ID of the contributor
    string public baseURI;  

    // Event is logged when an NFT is minted
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

    // Function allows users/ contributors to mint NFTs
    function mintNFT(address contributor, string memory tokenURI) public onlyOwner {
        require(contributor != address(0), "Invalid address");

        // Increment the counter for the next token ID
        uint256 tokenId = tokenCounter;
        tokenCounter++;

        // Mint the NFT to the users
        _safeMint(contributor, tokenId);
        _setTokenURI(tokenId, tokenURI);
        contributorTokens[contributor] = tokenId;

        
        emit NFTMinted(contributor, tokenId);
    }

    //  retrieves the base URI for metadata
    function getBaseURI() public view returns (string memory) {
        return baseURI;
    }

    // update the base URI if needed (for owner only)
    function setBaseURI(string memory _newBaseURI) public onlyOwner  {
        baseURI = _newBaseURI;
    }
}