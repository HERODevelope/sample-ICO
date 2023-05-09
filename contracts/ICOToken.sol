// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ICOToken is ERC20, Ownable {
    uint256 public constant INITIAL_SUPPLY = 5000;

    constructor() ERC20("ICO", "ICO") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}