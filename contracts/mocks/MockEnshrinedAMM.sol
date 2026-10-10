// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IEnshrinedAMM.sol";
import "../interfaces/IERC20.sol";

/**
 * @title MockEnshrinedAMM
 * @notice Realistic simulation of Tempo L1's native Enshrined AMM Precompile
 * @dev Replicates consensus-layer FX currency conversions between stablecoins
 */
contract MockEnshrinedAMM is IEnshrinedAMM {
    // Exchange rates scaled by 1e18 (e.g., rate = 0.92e18 means 1 tokenIn = 0.92 tokenOut)
    mapping(address => mapping(address => uint256)) public rates;

    event RateUpdated(address indexed tokenIn, address indexed tokenOut, uint256 newRate);
    event SwapExecuted(
        address indexed tokenIn,
        address indexed tokenOut,
        address indexed to,
        uint256 amountIn,
        uint256 amountOut
    );

    constructor() {}

    /**
     * @notice Set exchange rate between two stablecoins
     * @param tokenIn Source currency
     * @param tokenOut Target currency
     * @param rate Exchange rate scaled by 1e18
     */
    function setExchangeRate(address tokenIn, address tokenOut, uint256 rate) external {
        require(rate > 0, "Rate must be > 0");
        rates[tokenIn][tokenOut] = rate;
        emit RateUpdated(tokenIn, tokenOut, rate);
    }

    function getExchangeRate(
        address tokenIn,
        address tokenOut
    ) public view override returns (uint256) {
        uint256 r = rates[tokenIn][tokenOut];
        if (r == 0) {
            return 1e18; // Default 1:1 if not explicitly overridden
        }
        return r;
    }

    function getAmountOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) public view override returns (uint256) {
        uint256 rate = getExchangeRate(tokenIn, tokenOut);
        // Both tokens typically have 6 decimals (USDC/EURC)
        // amountOut = (amountIn * rate) / 1e18
        return (amountIn * rate) / 1e18;
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address tokenIn,
        address tokenOut,
        address to
    ) external override returns (uint256 amountOut) {
        require(amountIn > 0, "Zero input amount");
        require(to != address(0), "Zero recipient");

        amountOut = getAmountOut(amountIn, tokenIn, tokenOut);
        require(amountOut >= amountOutMin, "Slippage exceeded");

        // Pull tokenIn from caller (the Router)
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // Send tokenOut to recipient
        require(
            IERC20(tokenOut).balanceOf(address(this)) >= amountOut,
            "EnshrinedAMM: Insufficient reserve liquidity"
        );
        IERC20(tokenOut).transfer(to, amountOut);

        emit SwapExecuted(tokenIn, tokenOut, to, amountIn, amountOut);
    }
}
