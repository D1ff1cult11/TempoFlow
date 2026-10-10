// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IERC20.sol";
import "./interfaces/IMerchantSettlementVault.sol";

/**
 * @title MerchantSettlementVault
 * @notice Dedicated non-custodial multi-currency treasury vault for merchants on Tempo L1
 * @dev Enables secure merchant settlement isolation, multi-stablecoin accounting,
 *      and automated revenue split-forwarding.
 */
contract MerchantSettlementVault is IMerchantSettlementVault {
    address public override merchantOwner;

    // Optional automated forward split (e.g., 2000 = 20% to payroll reserve)
    address public autoForwardRecipient;
    uint256 public autoForwardBps;

    // Lightweight reentrancy protection
    uint256 private _unlocked = 1;

    modifier nonReentrant() {
        require(_unlocked == 1, "REENTRANCY_GUARD");
        _unlocked = 2;
        _;
        _unlocked = 1;
    }

    modifier onlyMerchant() {
        require(msg.sender == merchantOwner, "Only merchant owner");
        _;
    }

    constructor(address _merchantOwner) {
        require(_merchantOwner != address(0), "Zero merchant address");
        merchantOwner = _merchantOwner;
    }

    /**
     * @notice Deposit funds into the merchant vault
     * @param token Address of the stablecoin
     * @param amount Amount to deposit
     */
    function deposit(address token, uint256 amount) external override nonReentrant {
        require(token != address(0), "Zero token address");
        require(amount > 0, "Zero amount");

        IERC20(token).transferFrom(msg.sender, address(this), amount);

        if (autoForwardRecipient != address(0) && autoForwardBps > 0) {
            uint256 forwardAmount = (amount * autoForwardBps) / 10000;
            if (forwardAmount > 0) {
                IERC20(token).transfer(autoForwardRecipient, forwardAmount);
            }
        }

        emit DepositReceived(token, msg.sender, amount);
    }

    /**
     * @notice Withdraw funds from the vault to a recipient
     */
    function withdraw(
        address token,
        uint256 amount,
        address recipient
    ) external override onlyMerchant nonReentrant {
        require(recipient != address(0), "Zero recipient");
        require(amount > 0, "Zero amount");
        require(IERC20(token).balanceOf(address(this)) >= amount, "Insufficient balance");

        IERC20(token).transfer(recipient, amount);
        emit FundsWithdrawn(token, recipient, amount);
    }

    /**
     * @notice Configure optional automated split forwarding
     */
    function configureAutoForward(address recipient, uint256 bps) external onlyMerchant {
        require(bps <= 5000, "Max forward 50%");
        autoForwardRecipient = recipient;
        autoForwardBps = bps;
        emit SplitForwardConfigured(recipient, bps);
    }

    /**
     * @notice Query current balance of a specific token
     */
    function getBalance(address token) external view override returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}
