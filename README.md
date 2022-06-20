# Linear Token Vesting from Scratch

In Linear token vesting we add a cliff period in which nobbody can claim any tokens and after that the token are relased in regular intervals for claiming.
We add the durartion of vesitng so that all the tokens are released based on that in regular intervals.

In this we can :-

1. Add 3 Roles (Advisor, Partnerships, Mentors).
2. Dynamic TGE (Token Generation Event) for every role. % of Tokens to be released right after vesting.

Example: Create a Token Vesting Contract with 5% TGE for Advisors, 0 % TGE for Partnerships and 7% TGE for Mentors with 2 months cliff and 22 months linear vesting for all roles

## Environment Variables

To run this project, you will need to add the following environment variables to your .env file

```
    ROPSTEN_API_URL = "https://ropsten.infura.io/v3/YOUR_API_KEY"
    PRIVATE_KEY = "YOUR-METAMASK-PRIVATE_KEY"
```

## NPM Packages:

 - [Openzeppelin](https://docs.openzeppelin.com/)
 - [Hardhat Ethers](https://www.npmjs.com/package/hardhat-ethers)
 - [Chai](https://www.npmjs.com/package/chai)
 - [Ethers](https://www.npmjs.com/package/ethers)
 - [ethereum-waffle](https://www.npmjs.com/package/ethereum-waffle)
 - [dotenv](https://www.npmjs.com/package/dotenv)

## Tech Stack:
 - [Node](https://nodejs.org/en/)
 - [Hardhat](https://hardhat.org/tutorial/)
 - [Solidity](https://docs.soliditylang.org/en/v0.8.13)


## Run Locally:

Clone the github repo:
```
https://github.com/itsshantanu/NFTMarketPlace
```

Install Node Modules
```
npm install
```

Compile
```
npx hardhat compile
```

Test
```
npx hardhat test
```

Deploy on Localhost
```
npx hardhat node
npx hardhat run scripts/deploy.js --network localhost
```

Deploy on Ropsten
```
npx hardhat run scripts/deploy.js --network ropsten
```

Help
```
npx hardhat help
```

## Check at Rinkeby Test Net:
 - [MoonToken](https://ropsten.etherscan.io/address/0xcd7360527C8f8b6196192CC45f69a8F5D7b53da2)
 - [TokenVesiting](https://ropsten.etherscan.io/address/0xB837D083294b86F600104F6F0E56A8D4966Da50c)