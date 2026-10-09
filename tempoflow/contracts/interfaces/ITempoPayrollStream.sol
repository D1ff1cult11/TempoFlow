// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ITempoPayrollStream
 * @notice Interface for Continuous O(1) Streaming Payroll Engine
 */
interface ITempoPayrollStream {
    struct Stream {
        address employer;
        address employee;
        address token;
        uint256 ratePerSecond;
        uint256 startTime;
        uint256 stopTime;
        uint256 remainingBalance;
        uint256 lastClaimTime;
        bool isActive;
    }

    event StreamCreated(
        bytes32 indexed streamId,
        address indexed employer,
        address indexed employee,
        address token,
        uint256 ratePerSecond,
        uint256 totalAmount,
        uint256 startTime,
        uint256 stopTime
    );

    event StreamWithdrawn(
        bytes32 indexed streamId,
        address indexed employee,
        uint256 amount,
        uint256 remainingBalance
    );

    event StreamCancelled(
        bytes32 indexed streamId,
        address indexed employer,
        address indexed employee,
        uint256 employeePayout,
        uint256 employerRefund
    );

    function createStream(
        bytes32 streamId,
        address employee,
        address token,
        uint256 totalAmount,
        uint256 durationSeconds
    ) external;

    function availableToClaim(bytes32 streamId) external view returns (uint256);

    function withdrawFromStream(bytes32 streamId) external returns (uint256 claimedAmount);

    function cancelStream(bytes32 streamId) external returns (uint256 employeePayout, uint256 employerRefund);

    function getStream(bytes32 streamId) external view returns (Stream memory);
}
