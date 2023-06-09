// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICOToken.sol";
import "hardhat/console.sol";

contract ICO is Ownable {
    ICOToken public token;
    mapping(address => uint256) public deposits;
    uint256 public softcap = 0.1 ether;
    uint256 public hardcap = 1 ether;
    uint256 public minPurchase = 0.01 ether;
    uint256 public maxPurchase = 0.05 ether;
    uint256 public rate = 0.001 ether;

    uint256 public startTime = 1683676800;
    uint256 public endTime = 1683763200;
    uint256 public totalDeposit;

    event Deposit(address indexed investor, uint256 amount);
    event Withdraw(address indexed investor, uint256 amount);
    event Claim(address indexed investor, uint256 amount);

    constructor(
        address _token
        // uint256 _softcap,
        // uint256 _hardcap,
        // uint256 _minPurchase,
        // uint256 _maxPurchase,
        // uint256 _rate,
        // uint256 _startTime,
        // uint256 _endTime
    ) {
        token = ICOToken(_token);
        // softcap = _softcap;
        // hardcap = _hardcap;
        // minPurchase = _minPurchase;
        // maxPurchase = _maxPurchase;
        // rate = _rate;
        // startTime = _startTime;
        // endTime = _endTime;
    }

    modifier onlyDuringICO() {
        require(block.timestamp >= startTime, "ICO has not yet started.");
        require(block.timestamp <= endTime, "ICO has ended.");
        _;
    }

    function changeTime(uint256 start, uint256 end) external {
        startTime = start;
        endTime = end;
    }

    function deposit() external payable onlyDuringICO(){
        
        require(msg.value >= minPurchase, "Amount is less than minimum purchase amount");
        require(msg.value <= maxPurchase, "Amount is more than maximum purchase amount");
        // console.log(hardcap - address(this).balance, msg.value, hardcap - address(this).balance > msg.value);
        require(hardcap - totalDeposit >= msg.value, "Amount exceeds Hard cap");
        totalDeposit += msg.value;
        deposits[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external {
        require(block.timestamp > endTime, "ICO has not ended.");
        require(totalDeposit < softcap, "Softcap reached");
        require(deposits[msg.sender] > 0, "No deposits to withdraw");

        uint256 amount = deposits[msg.sender];
        deposits[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount);
    }

    function claim() external {
        // console.log(address(this).balance, hardcap);
        require(
            block.timestamp > endTime || totalDeposit == hardcap,
            "ICO has not ended or Hard cap not reached."
        );
        require(totalDeposit >= softcap, "Softcap not reached");
        require(deposits[msg.sender] > 0, "No deposits to withdraw");

        uint256 tokens = deposits[msg.sender] / rate;
        // require(token.balanceOf(address(this)) >= tokens, "Insufficient tokens in ICO contract");
        token.transfer(msg.sender, tokens);

        emit Claim(msg.sender, tokens);
    }
}