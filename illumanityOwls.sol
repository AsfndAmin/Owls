// SPDX-License-Identifier: unlicense
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract illuminatiOwls is ERC721, Ownable {
    using Strings for uint256;
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public _mintNftFee = 0.25 ether;
    
    uint256 _totalSupply;

    uint256 public _preSaleStartTime;
    uint256 public _preSaleEndTime;
    uint256 public _publicSaleStartTime;

    // Base URI
    string private _baseUriExtended;
    mapping (address => bool) public _preSaleWhitelistedAddresses;

    address public _owlAdminWallet = 0x930e7B59e522a9860E3D1175C8f0920fc202Aa77;

    constructor() ERC721("illuminati Owls", "ILL") {      
        _baseUriExtended = "https://api.illuminatiowls.com/nft/";
        _totalSupply   = 3333 ;
        _preSaleStartTime    = 1641774000 ; 
        _preSaleEndTime      = 1641786780 ; 
        _publicSaleStartTime = 1641860400 ; 
    }

    function baseURI() public view returns (string memory) {
        return _baseUriExtended; 
    } 

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
         
        return string(abi.encodePacked(baseURI(), tokenId.toString()));
    }

    function setPreSaleWhiteListAddress(address[] memory addresses) external onlyOwner() {
        for (uint i = 0; i < addresses.length; i++) {
            _preSaleWhitelistedAddresses[addresses[i]] = true;
        }
    }

    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _baseUriExtended = baseURI_;
    }

    function preSaleMint(uint256 tokenAmount) external payable {
        require(_preSaleWhitelistedAddresses[msg.sender], "ILLNFT, You are not whitelisted to mint pre sale token");
        require(tokenAmount <= 3, "ILLNFT: Max 3 NFTs per tx");
        require(block.timestamp >= _preSaleStartTime && block.timestamp <= _preSaleEndTime, "ILLNFT: Not the pre sale time for minting");
        require(_tokenIds.current() + tokenAmount <= _totalSupply, "ILLNFT: Max Limit Reached");
        require(msg.value == _mintNftFee * tokenAmount, "ILLNFT: Invalid Minting Fee");
       
       payable(_owlAdminWallet).transfer(msg.value);

        for(uint64 i = 0; i < tokenAmount; i++) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);
        }
    }

    function publicSaleMint(uint256 tokenAmount) external payable {
        require(block.timestamp >= _publicSaleStartTime, "ILLNFT: Public Sale not yet started");
        require(tokenAmount <= 20, "ILLNFT: Max 20 NFTs per tx");
        require(_tokenIds.current() + tokenAmount <= _totalSupply, "ILLNFT: Max Limit Reached");
        require(msg.value == _mintNftFee * tokenAmount, "ILLNFT: Invalid Minting Fee");

        payable(_owlAdminWallet).transfer(msg.value);

        for(uint i = 0; i < tokenAmount; i++) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);
        }
    }

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }
    
    function getCurrentTokenId() external view returns (uint256) {
        return _tokenIds.current();
    }
    
    function withdrawEth() external onlyOwner {
        payable(_owlAdminWallet).transfer(address(this).balance);
    }
}
