pragma solidity ^0.4.24;

import "./ERC721.sol";

contract Item is ERC721 {

    struct GameItem {
        string name; // Name of the Item
        uint level; // Item Level
        uint rarityLevel;  // 1 = normal, 2 = rare, 3 = epic, 4 = legendary
    }
    
    GameItem[] public items; // First Item has Index 0
    address public owner;
    mapping(address => bool) public whitelist; // Tracks whitelisted users
    mapping(address => uint[]) private userItems; // Tracks user's owned items

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);
    event BatchMint(address indexed admin, address[] users, uint[] tokenIds);
    event WhiteListAdded(address[] users);
    event WhiteListRemoved(address[] users);

    constructor () public {
        owner = msg.sender; // The Sender is the Owner; Ethereum Address of the Owner
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action.");
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Only whitelisted users can perform this action.");
        _;
    }

    // Change the owner of the contract
    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner address cannot be zero.");
        require(newOwner != owner, "New owner must be different.");
        owner = newOwner;
        emit OwnerChanged(msg.sender, newOwner);
    }

    // Admin batch mint NFTs to multiple users
    function batchMintByOwner(address[] users, uint[] tokenIds) public onlyOwner {
        require(users.length == tokenIds.length, "Users and token IDs array must have the same length.");
        for (uint i = 0; i < users.length; i++) {
            uint id = tokenIds[i];
            require(id < items.length, "Invalid token ID.");
            _mint(users[i], id);
            userItems[users[i]].push(id);
        }
        emit BatchMint(msg.sender, users, tokenIds);
    }

    // User mint by paying ether
    function mint() payable public {
        require(msg.value >= 0.01 ether, "Insufficient payment. Minimum is 0.01 ether.");
        uint id = items.length;
        items.push(GameItem("Purchased Item", 1, 1)); // Example item properties
        _mint(msg.sender, id);
        userItems[msg.sender].push(id);
    }

    // Whitelisted user mint
    function mintByWhiteList() public onlyWhitelisted {
        uint id = items.length;
        items.push(GameItem("Whitelist Item", 1, 2)); // Example item properties
        _mint(msg.sender, id);
        userItems[msg.sender].push(id);
    }

    // Add multiple users to whitelist
    function addWhiteList(address[] users) public onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            whitelist[users[i]] = true;
        }
        emit WhiteListAdded(users);
    }

    // Remove multiple users from whitelist
    function removeWhiteList(address[] users) public onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            whitelist[users[i]] = false;
        }
        emit WhiteListRemoved(users);
    }

    // Query user's owned items in batch
    function owner(address user) public view returns (uint[]) {
        return userItems[user];
    }
}
