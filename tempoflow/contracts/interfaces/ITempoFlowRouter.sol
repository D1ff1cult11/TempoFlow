// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ITempoFlowRouter
 * @notice Interface for TempoFlow settlement orchestrator on Tempo L1
 */
interface ITempoFlowRouter {
    event PaymentSettled(
        bytes32 indexed orderId,
        address indexed payer,
        address indexed merchant,
        address tokenPaid,
        address tokenReceived,
        uint256 amountPaid,
        uint256 amountReceived,
        uint256 timestamp
    );

    event SplitPaymentSettled(
        bytes32 indexed orderId,
        address indexed payer,
        address indexed merchant,
        address splitRecipient,
        uint256 merchantAmount,
        uint256 splitAmount
    );

    event FeeUpdated(uint256 newFeeBps);
    event TreasuryUpdated(address newTreasury);

    function executePayment(
        bytes32 orderId,
        address merchant,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) external returns (uint256 finalAmount);

    function executeSplitPayment(
        bytes32 orderId,
        address merchant,
        address splitRecipient,
        uint256 splitBps,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) external returns (uint256 merchantAmount, uint256 splitAmount);

    function enshrinedAMM() external view returns (address);
    function protocolTreasury() external view returns (address);
    function protocolFeeBps() external view returns (uint256);
}
