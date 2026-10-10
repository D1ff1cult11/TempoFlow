// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IERC20.sol";
import "./interfaces/IEnshrinedAMM.sol";
import "./interfaces/ITempoFlowRouter.sol";

/**
 * @title TempoFlowRouter
 * @notice High-performance merchant payment routing engine on Tempo L1
 * @dev Features sub-second settlement, enshrined FX conversion, non-custodial merchant routing,
 *      and automated 10 bps protocol monetization.
 */
contract TempoFlowRouter is ITempoFlowRouter {
    address public owner;
    address public override enshrinedAMM;
    address public override protocolTreasury;
    uint256 public override protocolFeeBps = 10; // Default 10 bps (0.10%)
    uint256 public constant MAX_FEE_BPS = 50;   // Hard cap 50 bps (0.50%)

    // Order replay prevention
    mapping(bytes32 => bool) public executedOrders;

    // Emergency circuit breaker
    bool public paused;

    // Lightweight reentrancy protection
    uint256 private _unlocked = 1;

    event Paused(address account);
    event Unpaused(address account);

    modifier nonReentrant() {
        require(_unlocked == 1, "REENTRANCY_GUARD");
        _unlocked = 2;
        _;
        _unlocked = 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor(address _enshrinedAMM, address _protocolTreasury) {
        require(_enshrinedAMM != address(0), "Zero AMM address");
        require(_protocolTreasury != address(0), "Zero treasury address");
        owner = msg.sender;
        enshrinedAMM = _enshrinedAMM;
        protocolTreasury = _protocolTreasury;
    }

    /**
     * @notice Execute an instant merchant settlement payment
     * @param orderId Unique identifier for the payment order (replay protected)
     * @param merchant Destination merchant address or settlement vault
     * @param tokenIn Input stablecoin paid by customer (e.g. USDC)
     * @param tokenOut Expected settlement stablecoin for merchant (e.g. EURC or USDC)
     * @param amountIn Gross amount paid
     * @param minAmountOut Slippage tolerance bound for conversion
     */
    function executePayment(
        bytes32 orderId,
        address merchant,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) external override nonReentrant whenNotPaused returns (uint256 finalAmount) {
        require(!executedOrders[orderId], "Order already executed");
        require(merchant != address(0), "Zero merchant address");
        require(tokenIn != address(0) && tokenOut != address(0), "Zero token address");
        require(amountIn > 0, "Zero amount");

        // 1. Effects: mark order as executed
        executedOrders[orderId] = true;

        // 2. Interactions: Pull input stablecoins from payer
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // 3. Calculate protocol fee (10 bps default)
        uint256 fee = (amountIn * protocolFeeBps) / 10000;
        uint256 netAmount = amountIn - fee;

        if (fee > 0) {
            IERC20(tokenIn).transfer(protocolTreasury, fee);
        }

        // 4. Settle to merchant (with Enshrined AMM conversion if cross-currency)
        if (tokenIn != tokenOut) {
            IERC20(tokenIn).approve(enshrinedAMM, netAmount);
            finalAmount = IEnshrinedAMM(enshrinedAMM).swapExactTokensForTokens(
                netAmount,
                minAmountOut,
                tokenIn,
                tokenOut,
                merchant
            );
        } else {
            finalAmount = netAmount;
            require(finalAmount >= minAmountOut, "Insufficient output amount");
            IERC20(tokenOut).transfer(merchant, finalAmount);
        }

        emit PaymentSettled(
            orderId,
            msg.sender,
            merchant,
            tokenIn,
            tokenOut,
            amountIn,
            finalAmount,
            block.timestamp
        );
    }

    /**
     * @notice Execute a payment with automated split routing (e.g. 80% merchant, 20% payroll/tax)
     */
    function executeSplitPayment(
        bytes32 orderId,
        address merchant,
        address splitRecipient,
        uint256 splitBps,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) external override nonReentrant whenNotPaused returns (uint256 merchantAmount, uint256 splitAmount) {
        require(!executedOrders[orderId], "Order already executed");
        require(merchant != address(0) && splitRecipient != address(0), "Zero address");
        require(splitBps > 0 && splitBps < 10000, "Invalid split bps");
        require(amountIn > 0, "Zero amount");

        executedOrders[orderId] = true;

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        uint256 fee = (amountIn * protocolFeeBps) / 10000;
        uint256 netAmount = amountIn - fee;

        if (fee > 0) {
            IERC20(tokenIn).transfer(protocolTreasury, fee);
        }

        uint256 totalOut;
        if (tokenIn != tokenOut) {
            IERC20(tokenIn).approve(enshrinedAMM, netAmount);
            totalOut = IEnshrinedAMM(enshrinedAMM).swapExactTokensForTokens(
                netAmount,
                minAmountOut,
                tokenIn,
                tokenOut,
                address(this)
            );
        } else {
            totalOut = netAmount;
            require(totalOut >= minAmountOut, "Insufficient output");
        }

        splitAmount = (totalOut * splitBps) / 10000;
        merchantAmount = totalOut - splitAmount;

        IERC20(tokenOut).transfer(splitRecipient, splitAmount);
        IERC20(tokenOut).transfer(merchant, merchantAmount);

        emit SplitPaymentSettled(
            orderId,
            msg.sender,
            merchant,
            splitRecipient,
            merchantAmount,
            splitAmount
        );

        emit PaymentSettled(
            orderId,
            msg.sender,
            merchant,
            tokenIn,
            tokenOut,
            amountIn,
            totalOut,
            block.timestamp
        );
    }

    // --- View Helpers ---

    function isOrderExecuted(bytes32 orderId) external view returns (bool) {
        return executedOrders[orderId];
    }

    // --- Admin Functions ---

    function pause() external onlyOwner {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner {
        paused = false;
        emit Unpaused(msg.sender);
    }

    function setProtocolFeeBps(uint256 newFeeBps) external onlyOwner {
        require(newFeeBps <= MAX_FEE_BPS, "Fee exceeds maximum");
        protocolFeeBps = newFeeBps;
        emit FeeUpdated(newFeeBps);
    }

    function setProtocolTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), "Zero address");
        protocolTreasury = newTreasury;
        emit TreasuryUpdated(newTreasury);
    }

    function setEnshrinedAMM(address newAMM) external onlyOwner {
        require(newAMM != address(0), "Zero address");
        enshrinedAMM = newAMM;
    }
}
