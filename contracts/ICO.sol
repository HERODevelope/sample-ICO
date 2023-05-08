pragma solidity ^0.8.0;

import "./ICOToken.sol";

contract ICO {
    ICOToken public token;
    address public owner;
    mapping(address => uint256) public deposit;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public minPurchaseAmount;
    uint256 public maxPurchaseAmount;
    bool public isICOActive;

    event Deposit(address indexed from, uint256 value);
    event Withdraw(address indexed to, uint256 value);
    event Claim(address indexed to, uint256 value);

    constructor(ICOToken _token, uint256 _softCap, uint256 _hardCap, uint256 _minPurchaseAmount, uint256 _maxPurchaseAmount) {
        token = _token;
        owner = msg.sender;
        softCap = _softCap;
        hardCap = _hardCap;
        minPurchaseAmount = _minPurchaseAmount;
        maxPurchaseAmount = _maxPurchaseAmount;
        isICOActive = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function depositFunds() public payable {
        require(isICOActive, "ICO is not active.");
        require(msg.value >= minPurchaseAmount && msg.value <= maxPurchaseAmount, "Invalid purchase amount.");
        deposit[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawFunds() public {
        require(!isICOActive, "ICO is still active.");
        require(address(this).balance < softCap, "Soft cap reached.");
        payable(msg.sender).transfer(deposit[msg.sender]);
        deposit[msg.sender] = 0;
        emit Withdraw(msg.sender, deposit[msg.sender]);
    }

    function claimTokens() public {
        require(!isICOActive || address(this).balance > hardCap, "ICO is still active.");
        require(address(this).balance >= softCap, "Soft cap not reached.");
        uint256 depositAmount = deposit[msg.sender];
        require(depositAmount > 0, "No deposit found for this address.");
        deposit[msg.sender] = 0;
        token.transfer(msg.sender, depositAmount);
        emit Claim(msg.sender, depositAmount);
    }

    function endICO() public onlyOwner {
        isICOActive = false;
    }
}