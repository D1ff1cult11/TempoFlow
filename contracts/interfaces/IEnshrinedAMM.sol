// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IEnshrinedAMM
 * @notice Interface for Tempo L1's native Enshrined AMM Precompile / Engine
 * @dev Enables zero-slippage / deterministic stablecoin FX swaps at validator consensus layer
 */
interface IEnshrinedAMM {
    /**
     * @notice Swaps an exact amount of input tokens for output tokens
     * @param amountIn Amount of input tokens to swap
     * @param amountOutMin Minimum acceptable output tokens (slippage tolerance)
     * @param tokenIn Input stablecoin address (e.g., USDC)
     * @param tokenOut Output stablecoin address (e.g., EURC)
     * @param to Recipient address for converted tokens
     * @return amountOut The actual amount of output tokens received
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address tokenIn,
        address tokenOut,
        address to
    ) external returns (uint256 amountOut);

    /**
     * @notice Simulates or quotes expected output amount for given input
     * @param amountIn Amount of input tokens
     * @param tokenIn Input stablecoin address
     * @param tokenOut Output stablecoin address
     * @return amountOut Expected amount of output tokens
     */
    function getAmountOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint256 amountOut);

    /**
     * @notice Returns the consensus FX exchange rate between two stablecoins
     * @param tokenIn Base currency token address
     * @param tokenOut Quote currency token address
     * @return rate FX exchange rate scaled to 1e18 (e.g., 1 USDC = 0.92 EURC -> 0.92e18)
     */
    function getExchangeRate(
        address tokenIn,
        address tokenOut
    ) external view returns (uint256 rate);
}
