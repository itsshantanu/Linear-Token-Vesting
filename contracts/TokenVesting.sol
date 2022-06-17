// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TokenVesting is Ownable,ReentrancyGuard {

    // Vesting 

    // 3 Roles - Advisors, Partners, Mentors
    uint256 public perAdvisorTokens;
    uint256 public perPartnershipTokens;
    uint256 public perMentorTokens;

    // TGE for 3 roles
    uint256 public AdvisorsTGE = 5;
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
    uint256 public totalPartnerships;
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
        bool vestingRevoked;
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

        if (_role == 0) {
            totalAdvisors++;
        } else if (_role == 1) {
            totalPartnerships++;
        } else {
            totalMentors++;
        }

        emit AddBeneficiary(
            _beneficiary,
             _role
        );
    }

    // It will set Dynamic TGE for different Roles

    function setTGE(uint8 _role, uint256 _percent) external onlyOwner {
        if (_role == 0) {
            AdvisorsTGE = _percent;
        } else if (_role == 1) {
            PartnershipsTGE = _percent;
        } else {
            MentorsTGE = _percent;
        }
    }

    event VestingStarted(
        uint256 cliff, 
        uint256 duration
    );

    // It will start the vesting by entering cliff period and duration

    function startVesting(uint256 _cliff, uint256 _duration) external onlyOwner {
        require(vestingStarted == false, "vesting already started");
        require(_cliff > 0 && _duration > 0, "Cliff and Duration should be greater than 0");
        totalTokens = token.balanceOf(address(this));
        cliff = _cliff;
        duration = _duration;
        vestingStarted = true;
        startTime = block.timestamp;

        tokenCalculatePerRole();

        emit VestingStarted(
            cliff, 
            duration
        );
    }

    // It will calculate tokens for every Role.

    function tokenCalculatePerRole() private {
        perAdvisorTokens = ((totalTokens * AdvisorsTGE * totalAdvisors) / denominator);
        perPartnershipTokens = ((totalTokens * PartnershipsTGE * totalPartnerships) / denominator);
        perMentorTokens = ((totalTokens * MentorsTGE * totalMentors) /  denominator);
    }

    // It will track the claim status of the tokens.

    function tokenClaimStatus() public returns(uint256) {

        Beneficiary memory beneficiaryMem = beneficiaries[msg.sender];

        uint8 roleCheck = beneficiaryMem.role;
        uint256 claimTokens = beneficiaryMem.totalTokensClaimed;

        if (roleCheck == 0) {
            tokensAvailable = getAvailableTokens(perAdvisorTokens);
        } else if (roleCheck == 1) {
            tokensAvailable = getAvailableTokens(perPartnershipTokens);
        } else {
            tokensAvailable = getAvailableTokens(perMentorTokens);
        }
        return tokensAvailable - claimTokens;
    }

    // It will calculate and return available token

    function getAvailableTokens(uint256 perRoleTokens) internal returns (uint256)
    {
        uint256 Time = block.timestamp - startTime - cliff;
        if (Time >= duration) {
            return tokensAvailable = perRoleTokens;
        } else {
            return tokensAvailable = (perRoleTokens * Time) / duration;
        }
    }

    event TokensClaimed(
        address beneficiary, 
        uint256 tokens
    );

    // It will check all the claimtoken and condition. It will also check whether you claim token last month or not. 

    function claimToken() external nonReentrant {
        
        Beneficiary memory beneficiaryMem = beneficiaries[msg.sender];

        require(vestingStarted == true, "vesting not strated");
        require(beneficiaryMem.isBeneficiary == true, "You are not beneficiary");
        require(beneficiaryMem.vestingRevoked == false, "vesting has been Revoked");
        require(block.timestamp >= cliff + startTime, "vesting is in cliff period");
        require(block.timestamp - beneficiaryMem.lastTimeClaimed > 2592000, "Token already claimed within last month");
        uint8 roleCheck = beneficiaryMem.role;
        uint256 claimedToken = beneficiaryMem.totalTokensClaimed;
        

        if (roleCheck == 0) {
            require(claimedToken < perAdvisorTokens, "you have claimed all Tokens");
        } else if (roleCheck == 1) {
            require(claimedToken < perPartnershipTokens, "you have claimed all Tokens");
        } else {
            require(claimedToken < perMentorTokens, "you have claimed all Tokens");
        }
        uint256 tokens = tokenClaimStatus();

        token.transfer(msg.sender, tokens);
        beneficiaries[msg.sender].lastTimeClaimed = block.timestamp;
        beneficiaries[msg.sender].totalTokensClaimed += tokens;

        emit TokensClaimed(
            msg.sender, 
            tokens
        );
    }

    function revokeVesting(address _beneficiary) external onlyOwner {
        require(!beneficiaries[_beneficiary].vestingRevoked, "vesting already Revoked");

        beneficiaries[_beneficiary].vestingRevoked = true;
    }

}