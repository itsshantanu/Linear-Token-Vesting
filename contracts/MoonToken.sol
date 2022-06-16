// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MoonToken is ERC20 {
    address public admin;
    constructor(uint256 initialSupply) ERC20("MoonToken", "MOON") {
        _mint(msg.sender, initialSupply * 10 ** 18);
        admin = msg.sender;
    }

    function burn(uint amount) external {
        _burn(msg.sender, amount);
    }
}