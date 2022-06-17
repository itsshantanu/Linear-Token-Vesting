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
    uint256 public AdvisorsTGE = 5;
    uint256 public PartnersTGE = 10;
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

    uint startTime;
    uint256 tokensAvailable;

    enum Roles {
        advisor,
        partner,
        mentor
    }

    Roles private role;

    struct Beneficiary {
        uint8 role;
        uint256 totalTokensClaimed;
        uint256 lastTimeClaimed;
        bool isBeneficiary;
        bool isVestingRevoked;
    }

    mapping(address => Beneficiary) public beneficiaries;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    event AddBeneficiary(
        address beneficiary,
        uint8 role
    );

    // It will add new Beneficiary. Only Owner can do this.

    function addBeneficiary(address _beneficiary, uint8 _role) external onlyOwner{
        require(_beneficiary != address(0), "0 Address entered. Enter a valid address");
        require(beneficiaries[_beneficiary].isBeneficiary == false,"Beneficiary already present");
        require(vestingStarted == false, "Vesting already started");

        beneficiaries[_beneficiary].role = _role;
        beneficiaries[_beneficiary].isBeneficiary = true;

        emit AddBeneficiary(_beneficiary, _role);

        if (_role == 0) {
            totalAdvisors++;
        } else if (_role == 1) {
            totalPartners++;
        } else {
            totalMentors++;
        }
    }

    event VestingStarted(
        uint256 cliff, 
        uint256 duration
    );

    // It will start the vesting by entering cliff period and duration

    function startVesting(uint256 _cliff, uint256 _duration) external onlyOwner {
        require(vestingStarted == false, 'vesting already started');
        require(_cliff > 0 && _duration > 0, "Cliff and Duration should be greater than 0");
        totalTokens = token.balanceOf(address(this));
        cliff = _cliff;
        duration = _duration;
        vestingStarted = true;
        startTime = block.timestamp;

        tokenCalculatePerRole();

        emit VestingStarted(cliff, duration);
    }

    // It will calculate tokens for every Role.

    function tokenCalculatePerRole() private {
        perAdvisorTokens = ((totalTokens * AdvisorsTGE * totalAdvisors) / denominator);
        perPartnerTokens = ((totalTokens * PartnersTGE * totalPartners) / denominator);
        perMentorTokens = ((totalTokens * MentorsTGE * totalMentors) /  denominator);
    }

}