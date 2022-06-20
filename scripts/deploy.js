const hre = require('hardhat');
const { BigNumber } = require('ethers');

async function main() {
  const MoonToken = await hre.ethers.getContractFactory('MoonToken');
  const initialSupply = BigNumber.from(10000);
  const moonToken = await MoonToken.deploy(initialSupply);

  await moonToken.deployed();

  console.log('moonToken deployed to:', moonToken.address);

  // For vesting contract

  const ToknVesting = await hre.ethers.getContractFactory('TokenVesting');
  const tokenVesting = await ToknVesting.deploy(moonToken.address);

  await tokenVesting.deployed();

  console.log('TokenVesting deployed to:', tokenVesting.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
