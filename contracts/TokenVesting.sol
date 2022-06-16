// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TokenVesting is Ownable,ReentrancyGuard {

    // Vesting 

    // 3 Roles - Advisors, Partners, Mentors
    uint256 public perAdvisorTokens;
    uint256 public perPartnerTokens;
    uint256 public perMentorTokens;

    // TGE for 3 roles
    uint256 public AdvisorTGE = 5;
    uint256 public PartnershipsTGE = 10;
    uint256 public MentorsTGE = 9;
    uint256 public denominator = 100;

    IERC20 private token;  
    uint256 private totalTokens;
    uint256 private start;
    uint256 private cliff;
    uint256 private duration;
    address private beneficiary;
    bool public vestingStarted;

    // Total in each role
    uint256 public totalAdvisors;
    uint256 public totalPartners;
    uint256 public totalMentors;

    // start date & end date
    uint startTime;
    uint256 tokensAvailable;
}