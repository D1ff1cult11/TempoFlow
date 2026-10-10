// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IMerchantSettlementVault
 * @notice Non-custodial merchant treasury vault interface
 */
interface IMerchantSettlementVault {
    event DepositReceived(address indexed token, address indexed from, uint256 amount);
    event FundsWithdrawn(address indexed token, address indexed recipient, uint256 amount);
    event SplitForwardConfigured(address indexed recipient, uint256 bps);

    function deposit(address token, uint256 amount) external;
    function withdraw(address token, uint256 amount, address recipient) external;
    function merchantOwner() external view returns (address);
    function getBalance(address token) external view returns (uint256);
}
