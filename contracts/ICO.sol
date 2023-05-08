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
    uint256 public startTime;
    uint256 public endTime;
    bool public isICOActive;

    event Deposit(address indexed from, uint256 value);
    event Withdraw(address indexed to, uint256 value);
    event Claim(address indexed to, uint256 value);

    constructor(
        ICOToken _token,
        uint256 _softCap,
        uint256 _hardCap,
        uint256 _minPurchaseAmount,
        uint256 _maxPurchaseAmount,
        uint256 _startTime,
        uint256 _endTime
    ) {
        token = _token;
        owner = msg.sender;
        softCap = _softCap;
        hardCap = _hardCap;
        minPurchaseAmount = _minPurchaseAmount;
        maxPurchaseAmount = _maxPurchaseAmount;
        startTime = _startTime;
        endTime = _endTime;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier onlyDuringICO() {
        require(block.timestamp >= startTime, "ICO has not yet started.");
        require(block.timestamp <= endTime, "ICO has ended.");
        require(address(this).balance < hardCap, "Hard cap reached.");
        _;
    }

    function depositFunds() public payable onlyDuringICO(){
        require(
            msg.value >= minPurchaseAmount && msg.value <= maxPurchaseAmount,
            "Invalid purchase amount."
        );
        deposit[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawFunds() public {
        require(block.timestamp > endTime, "ICO has not ended.");
        require(address(this).balance < softCap, "Soft cap reached.");
        payable(msg.sender).transfer(deposit[msg.sender]);
        deposit[msg.sender] = 0;
        emit Withdraw(msg.sender, deposit[msg.sender]);
    }

    function claimTokens() public {
        require(
            block.timestamp > endTime || address(this).balance >= hardCap,
            "ICO has not ended or Hard cap not reached."
        );
        require(address(this).balance >= softCap, "Soft cap not reached.");
        uint256 depositAmount = deposit[msg.sender];
        require(depositAmount > 0, "No deposit found for this address.");
        deposit[msg.sender] = 0;
        uint256 tokenAmount = depositAmount / 0.001 ether;
        token.transfer(msg.sender, tokenAmount);
        emit Claim(msg.sender, tokenAmount);
    }
}
