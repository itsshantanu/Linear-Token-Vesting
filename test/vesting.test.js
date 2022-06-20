const { expect } = require('chai');
const { BigNumber } = require('ethers');
const { ethers } = require('hardhat');

describe('Vesting Contract', function () {
	let moonToken;
	let vesting;
	let manager;
	let addr1;
	let addr2;
	let addr3;
	let addrs;

	beforeEach(async () => {
		[manager, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();

		const MoonTokenInstance = await hre.ethers.getContractFactory(
			'MoonToken'
		);
		const totalSupply = BigNumber.from(10000000);
		moonToken = await MoonTokenInstance.deploy(totalSupply);
		await moonToken.deployed();

		// For Vesting Contract
		const TokenVesitngInstance = await hre.ethers.getContractFactory(
			'TokenVesting'
		);
		vesting = await TokenVesitngInstance.deploy(moonToken.address);
		await vesting.deployed();

		await moonToken.transfer(
			vesting.address,
			moonToken.balanceOf(manager.address)
		);

		await vesting.connect(manager).addBeneficiary(addr1.address, 0);
		await vesting.connect(manager).addBeneficiary(addr2.address, 1);
		await vesting.connect(manager).addBeneficiary(addr3.address, 2);
	});

	describe('Deployment', async () => {
		it('Should return the correct name', async () => {
			expect(await moonToken.name()).to.equal('MoonToken');
		  });
	});

	describe('Transactions', async () => {
		it('Only manager should be able to add beneficiaries', async () => {
			expect(
				vesting.connect(addr1).addBeneficiary(addr1.address, 0)
			).to.be.revertedWith('Ownable: caller is not the manager');
		});

		it('should start vesting with cliff and duration', async () => {
			await vesting.startVesting(
				2 * 2628288,
				22 * 2628288
			); // Cliff = 2 months, Duration = 22 months

			expect(await vesting.vestingStarted()).to.equal(true);
		});

		it('Should not claim tokens in cliff period', async () => {
			await vesting.startVesting(
				2 * 2628288,
				22 * 2628288
			);

			expect(vesting.connect(addr1).claimToken()).to.be.revertedWith();
		});

		it('Should claim tokens after cliff period ', async () => {
			await vesting.startVesting(30, 60);

			await hre.network.provider.send('hardhat_mine', ['0x3e8', '0x3c']);
			const balanceBefore = await moonToken
				.connect(addr1)
				.balanceOf(addr1.address);

			await vesting.connect(addr1).claimToken();

			const balanceAfter = await moonToken
				.connect(addr1)
				.balanceOf(addr1.address);

			expect(balanceBefore).to.be.not.equal(balanceAfter);
		});
	});
});
