// SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

// import "hardhat/console.sol";
const { ethers } = require("hardhat");
const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("ICO", function () {
    let ico;
    let token;
    let owner;
    let investor1;
    let investor2;

    const softcap = ethers.utils.parseEther("0.1");
    const hardcap = ethers.utils.parseEther("1");
    const minPurchase = ethers.utils.parseEther("0.01");
    const maxPurchase = ethers.utils.parseEther("0.05");
    const rate = ethers.utils.parseEther("0.001");

    function datetoTimestamp(_dateString) {
      // Convert the input date string to a Date object
      const date = new Date(_dateString);
      
      // Get the Unix timestamp of the input date
      const timestamp = Math.floor(date.getTime() / 1000);
      
      return timestamp;
    }

    const startTime = datetoTimestamp("2023/05/07 02:00:00"); 
    const endTime = datetoTimestamp("2023/05/10 02:00:00"); 
    async function prepare() {
        [owner, investor1, investor2] = await ethers.getSigners();

        const ICOToken = await ethers.getContractFactory("ICOToken");
        token = await ICOToken.deploy();
        await token.deployed();

        const ICO = await ethers.getContractFactory("ICO");
        ico = await ICO.deploy(
            token.address,
            softcap,
            hardcap,
            minPurchase,
            maxPurchase,
            rate,
            startTime,
            endTime
        );
        await ico.deployed();

        await token.transfer(ico.address, 5000);
    };

    beforeEach(async function(){
      await loadFixture(prepare);
    })

    it("should allow investors to deposit funds", async function () {
        // Investor 1 deposits 0.04 BNB
        await ico.connect(investor1).deposit({ value: ethers.utils.parseEther("0.04") });

        // Investor 2 deposits 0.02 BNB
        await ico.connect(investor2).deposit({ value: ethers.utils.parseEther("0.02") });

        // Check the deposit balances
        expect(await ico.deposits(investor1.address)).to.equal(ethers.utils.parseEther("0.04"));
        expect(await ico.deposits(investor2.address)).to.equal(ethers.utils.parseEther("0.02"));
    });

    // it("should not allow deposits outside of ICO period", async function () {
    //     // Wait for ICO to end
    //     // await ethers.provider.send("evm_setNextBlockTimestamp", [endTime + 1]);

    //     // Investor 1 tries to deposit 0.06 BNB
    //     await expect(ico.connect(investor1).deposit({ value: ethers.utils.parseEther("0.06") })).to.be.reverted;

    //     // Investor 1 tries to deposit 0.005 BNB
    //     await expect(ico.connect(investor1).deposit({ value: ethers.utils.parseEther("0.005") })).to.be.reverted;
    // });

    it("should not allow deposits below minimum purchase amount", async function () {
        // Investor 1 tries to deposit 0.005 BNB
        await expect(ico.connect(investor1).deposit({ value: ethers.utils.parseEther("0.005") })).to.be.revertedWith(
            "Amount is less than minimum purchase amount"
        );
    });

    it("should not allow deposits above maximum purchase amount", async function () {
        // Investor 1 tries to deposit 0.06 BNB
        await expect(ico.connect(investor1).deposit({ value: ethers.utils.parseEther("0.06") })).to.be.revertedWith(
            "Amount is more than maximum purchase amount"
        );
    });

    it("should not allow deposits above hardcap", async function () {
        // Investor 1 deposits 0.5 BNB
        for (let i=1; i<=18; i++){
          await ico.connect(investor1).deposit({ value: ethers.utils.parseEther("0.05") });
        }

        // Investor 2 tries to deposit 0.6 BNB
        await expect(ico.connect(investor2).deposit({ value: ethers.utils.parseEther("0.05") })).to.be.revertedWith(
            "Amount exceeds Hard cap"
        );
    });

    it("should allow investors to withdraw funds after ICO if softcap is not reached", async function () {
        // Investor 1 deposits 0.04 BNB
        await ico.connect(investor1).deposit({ value: ethers.utils.parseEther("0.04") });

        // Wait for ICO to end

        await ethers.provider.send("evm_setNextBlockTimestamp", [endTime + 1]);

        // Investor 1 withdraws their deposit
        const initialBalance = await ethers.provider.getBalance(investor1.address);
        await ico.connect(investor1).withdraw();
        const finalBalance = await ethers.provider.getBalance(investor1.address);
        expect(await ico.deposits(investor1.address)).to.equal(0);
        // expect(finalBalance.sub(initialBalance)).to.equal(ethers.utils.parseEther("0.04"));
    });

    it("should not allow investors to withdraw funds after ICO if softcap is reached", async function () {
        // Investor 1 deposits 0.08 BNB
        await ico.connect(investor1).deposit({ value: ethers.utils.parseEther("0.04") });
        await ico.connect(investor1).deposit({ value: ethers.utils.parseEther("0.04") });

        // Investor 2 deposits 0.02 BNB
        await ico.connect(investor2).deposit({ value: ethers.utils.parseEther("0.02") });

        await expect(ico.connect(investor1).withdraw()).to.be.revertedWith("ICO has not ended.");

        // Wait for ICO to end
        await ethers.provider.send("evm_setNextBlockTimestamp", [endTime + 1]);

        // Softcap is reached, so investors cannot withdraw their funds
        await expect(ico.connect(investor1).withdraw()).to.be.revertedWith("Softcap reached");
        await expect(ico.connect(investor2).withdraw()).to.be.revertedWith("Softcap reached");
    });

    it("should allow investors to claim tokens after ICO if softcap is reached", async function () {
        // Investor 1 deposits 0.08 BNB
        await ico.connect(investor1).deposit({ value: ethers.utils.parseEther("0.04") });
        await ico.connect(investor1).deposit({ value: ethers.utils.parseEther("0.04") });

        // Investor 2 deposits 0.02 BNB
        await ico.connect(investor2).deposit({ value: ethers.utils.parseEther("0.02") });

        // Wait for ICO to end
        await ethers.provider.send("evm_setNextBlockTimestamp", [endTime + 1]);

        // Softcap is reached, so investors can claim their tokens
        const initialBalance1 = await token.balanceOf(investor1.address);
        const initialBalance2 = await token.balanceOf(investor2.address);
        await ico.connect(investor1).claim();
        await ico.connect(investor2).claim();
        const finalBalance1 = await token.balanceOf(investor1.address);
        const finalBalance2 = await token.balanceOf(investor2.address);
        
        expect(finalBalance1.sub(initialBalance1)).to.equal(ethers.utils.parseEther("80"));
        expect(finalBalance2.sub(initialBalance2)).to.equal(ethers.utils.parseEther("20"));
    });

    it("should not allow investors to claim tokens after ICO if softcap is not reached", async function () {
        // Investor 1 deposits 0.04 BNB
        await ico.connect(investor1).deposit({ value: ethers.utils.parseEther("0.04") });

        // Wait for ICO to end
        await ethers.provider.send("evm_setNextBlockTimestamp", [endTime + 1]);

        // Softcap is not reached, so investors cannot claim their tokens
        await expect(ico.connect(investor1).claim()).to.be.revertedWith("Softcap not reached");
    });
});