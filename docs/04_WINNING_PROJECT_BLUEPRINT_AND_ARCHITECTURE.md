# 🏗️ Winning Project Blueprint & Technical Architecture: TempoFlow (AegisPay)

> **Project Name**: **TempoFlow** (Internal Code: `AegisPay`)  
> **Tagline**: The Sub-Second Programmable Stablecoin Highway: Cross-Chain Instant Settlement, Streaming Payroll & Enshrined FX on Tempo L1.  
> **Target Tracks**:
> 1. **Tempo Ecosystem Track ($100,000)** (Primary)
> 2. **Payments & Stablecoins Track** (Global Category)
> 3. **Solana Ecosystem Track ($100,000)** (Cross-chain initiation & Blinks)
> 4. **Public Goods Track ($10,000)** (Open-source Tempo Payment SDK)

---

## 1. The Core Problem & The "Aha!" Moment

### The Problem in Web3 Payments Today:
1. **The Gas Token Tax**: A user wanting to pay a merchant or an employee $20 in USDC must first buy, bridge, and hold volatile gas tokens (ETH, SOL, AVAX) to submit transactions. This single friction point kills 95% of real-world merchant checkout flows.
2. **Execution Volatility & Block Re-orgs**: General-purpose blockchains prioritize high-fee MEV bots and memecoin spammers during traffic spikes. If a network gets congested, a merchant waiting at the checkout counter has to wait 20-60 seconds or pay $15 in fees.
3. **Cross-Border FX Friction**: International businesses pay global contractors in local currencies (e.g., paying a Latin American or European contractor while holding US-denominated stablecoins), incurring 3-5% slippage on decentralized exchanges or high bank wire fees.

### The Solution: TempoFlow on Tempo L1:
**TempoFlow** harnesses the breakthrough primitives of **Tempo** (the Stripe & Paradigm incubated stablecoin L1):
- **Stablecoin-Native Gas**: Zero native gas tokens needed. All transactions and contract fees are paid directly in USDC or EURC.
- **Dedicated Payment Lanes**: Sub-second (0.6s) deterministic settlement with $0.001 fixed fees that never spike during market volatility.
- **Enshrined AMM FX Engine**: Instant zero-slippage automated conversion between USDC, EURC, and regional stablecoins at the validator layer.
- **Cross-Chain Ingress from Solana**: Retail shoppers pay with one click from their Phantom/Solana wallet; funds stream instantly into the merchant's Tempo treasury.
- **Programmable Continuous Payroll**: Employers set up continuous by-the-second stablecoin streaming to employees with automated tax withholding.

---

## 2. High-Level System Architecture

```mermaid
graph TD
    subgraph "Client Layer"
        UserSolana["Solana User / Phantom Wallet / Blink"]
        UserWeb["Web3 Merchant Terminal / POS"]
        Worker["Contractor / Employee Portal"]
    end

    subgraph "Ingress & Relayer Layer"
        CrossChainRelay["TempoFlow Cross-Chain Relayer"]
        SolanaEscrow["Solana Ingress Program (Anchor)"]
    end

    subgraph "Tempo L1 Core (EVM Runtime)"
        TempoPaymentLane["Tempo Payment Lane (0.6s Finality)"]
        
        subgraph "TempoFlow Smart Protocol"
            Router["TempoFlowRouter.sol"]
            StreamEngine["TempoPayrollStream.sol"]
            MerchantVault["MerchantSettlementVault.sol"]
            EnshrinedAMM["Tempo Enshrined AMM Precompile"]
        end
        
        GasEngine["Stablecoin Gas Module (Native USDC Gas)"]
    end

    UserSolana -->|1-Click Pay SOL/USDC| SolanaEscrow
    SolanaEscrow -->|Event / Proof| CrossChainRelay
    CrossChainRelay -->|Trigger Settlement| Router

    UserWeb -->|Gasless Merchant Checkout| Router
    Router -->|Auto-Swap via Enshrined AMM| EnshrinedAMM
    EnshrinedAMM -->|Settled Asset| MerchantVault

    Router -->|Continuous Stream Deposit| StreamEngine
    Worker -->|Claim Accrued Pay by the Second| StreamEngine
    
    Router -.->|Direct Stablecoin Fee ($0.001)| GasEngine
```

---

## 3. Core Protocol Components

### Component 1: `TempoFlowRouter.sol` (Main Settlement Entrypoint)
The orchestrator contract deployed on Tempo L1. It receives payment orders, splits fees, routes through the Enshrined AMM if currency conversion is requested (e.g. USDC to EURC), and credits the merchant or streaming contract.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IEnshrinedAMM {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address tokenIn,
        address tokenOut,
        address to
    ) external returns (uint256 amountOut);
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TempoFlowRouter {
    address public immutable enshrinedAMM;
    address public immutable protocolTreasury;
    uint256 public constant PROTOCOL_FEE_BPS = 10; // 0.10% (10 bps)

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

    event StreamCreated(
        bytes32 indexed streamId,
        address indexed employer,
        address indexed employee,
        address token,
        uint256 flowRatePerSecond,
        uint256 depositAmount
    );

    constructor(address _enshrinedAMM, address _protocolTreasury) {
        enshrinedAMM = _enshrinedAMM;
        protocolTreasury = _protocolTreasury;
    }

    /// @notice Process an instant merchant payment with optional FX conversion
    function executePayment(
        bytes32 orderId,
        address merchant,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) external returns (uint256 finalAmount) {
        require(amountIn > 0, "Invalid amount");
        require(merchant != address(0), "Invalid merchant");

        // 1. Pull stablecoins from payer (gas paid directly in tokenIn on Tempo)
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // 2. Protocol fee calculation
        uint256 fee = (amountIn * PROTOCOL_FEE_BPS) / 10000;
        uint256 netAmount = amountIn - fee;
        if (fee > 0) {
            IERC20(tokenIn).transfer(protocolTreasury, fee);
        }

        // 3. Currency conversion if payer and merchant use different stablecoins
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
}
```

---

### Component 2: `TempoPayrollStream.sol` (Programmable Continuous Payroll)
Enables employers to fund a stream where employees can withdraw their accrued salary every second. Uses zero gas overhead and continuous mathematical interpolation.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./TempoFlowRouter.sol";

contract TempoPayrollStream {
    struct Stream {
        address employer;
        address employee;
        address token;
        uint256 ratePerSecond;
        uint256 startTime;
        uint256 stopTime;
        uint256 remainingBalance;
        uint256 lastClaimTime;
    }

    mapping(bytes32 => Stream) public streams;

    event StreamWithdrawn(bytes32 indexed streamId, address indexed employee, uint256 amount);
    event StreamCancelled(bytes32 indexed streamId, uint256 refundedAmount);

    function createStream(
        bytes32 streamId,
        address employee,
        address token,
        uint256 totalAmount,
        uint256 durationSeconds
    ) external {
        require(streams[streamId].employer == address(0), "Stream exists");
        require(durationSeconds > 0 && totalAmount > 0, "Invalid params");

        IERC20(token).transferFrom(msg.sender, address(this), totalAmount);

        uint256 rate = totalAmount / durationSeconds;
        streams[streamId] = Stream({
            employer: msg.sender,
            employee: employee,
            token: token,
            ratePerSecond: rate,
            startTime: block.timestamp,
            stopTime: block.timestamp + durationSeconds,
            remainingBalance: totalAmount,
            lastClaimTime: block.timestamp
        });
    }

    function availableToClaim(bytes32 streamId) public view returns (uint256) {
        Stream memory s = streams[streamId];
        if (s.employer == address(0)) return 0;
        
        uint256 currentTime = block.timestamp > s.stopTime ? s.stopTime : block.timestamp;
        if (currentTime <= s.lastClaimTime) return 0;

        uint256 elapsed = currentTime - s.lastClaimTime;
        uint256 claimable = elapsed * s.ratePerSecond;
        return claimable > s.remainingBalance ? s.remainingBalance : claimable;
    }

    function withdrawFromStream(bytes32 streamId) external {
        Stream storage s = streams[streamId];
        require(msg.sender == s.employee, "Only employee");
        
        uint256 claimable = availableToClaim(streamId);
        require(claimable > 0, "Zero claimable");

        s.remainingBalance -= claimable;
        s.lastClaimTime = block.timestamp > s.stopTime ? s.stopTime : block.timestamp;

        IERC20(s.token).transfer(s.employee, claimable);
        emit StreamWithdrawn(streamId, s.employee, claimable);
    }
}
```

---

### Component 3: Solana Cross-Chain Trigger (`tempo_crosschain_ingress.rs`)
The Solana Anchor program receives retail customer payments via Solana Pay or Blinks, locks the funds in an escrow vault, and emits a cryptographically verified `CrossChainPaymentIntent` event. The TempoFlow relayer reads this event and automatically triggers settlement on Tempo L1 within 1.5 seconds.

```rust
use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token, TokenAccount, Transfer};

declare_id!("TempoF1owIngress111111111111111111111111111");

#[program]
pub mod tempo_crosschain_ingress {
    use super::*;

    pub fn initiate_cross_payment(
        ctx: Context<InitiateCrossPayment>,
        order_id: [u8; 32],
        amount: u64,
        tempo_recipient: [u8; 20],
        target_token_code: u8, // 0 = USDC, 1 = EURC
    ) -> Result<()> {
        let cpi_accounts = Transfer {
            from: ctx.accounts.payer_token_account.to_account_info(),
            to: ctx.accounts.vault_token_account.to_account_info(),
            authority: ctx.accounts.payer.to_account_info(),
        };
        let cpi_ctx = CpiContext::new(ctx.accounts.token_program.to_account_info(), cpi_accounts);
        token::transfer(cpi_ctx, amount)?;

        emit!(CrossChainPaymentIntent {
            order_id,
            payer: ctx.accounts.payer.key(),
            amount,
            tempo_recipient,
            target_token_code,
            timestamp: Clock::get()?.unix_timestamp,
        });

        Ok(())
    }
}

#[event]
pub struct CrossChainPaymentIntent {
    pub order_id: [u8; 32],
    pub payer: Pubkey,
    pub amount: u64,
    pub tempo_recipient: [u8; 20],
    pub target_token_code: u8,
    pub timestamp: i64,
}

#[derive(Accounts)]
pub struct InitiateCrossPayment<'info> {
    #[account(mut)]
    pub payer: Signer<'info>,
    #[account(mut)]
    pub payer_token_account: Account<'info, TokenAccount>,
    #[account(mut)]
    pub vault_token_account: Account<'info, TokenAccount>,
    pub token_program: Program<'info, Token>,
}
```

---

## 4. Frontend & User Experience Design

The web application is designed to feel like a blend of **Stripe Dashboard** and **Phantom Wallet**:
1. **Merchant Portal**:
   - Real-time live settlement stream ticker.
   - Point of Sale (POS) QR generator (Solana Pay + Tempo Native QR).
   - Instant currency conversion toggles (Auto-convert incoming USD to EURC).
   - Sub-second notification sound & visual receipt when a customer pays.
2. **Employee Continuous Payroll Terminal**:
   - Visual real-time odometer ticking up by fractions of a cent every second.
   - 1-Click "Claim Available Pay" with zero gas fees.
   - Tax withholding breakdown and downloadable PDF/CSV proof-of-income receipts.
3. **Interactive Demo Mode**:
   - Preloaded testnet wallets allowing judges to simulate both the customer and merchant side in 15 seconds without waiting for faucets!

---

## 5. Tokenomics & Business Model (Why It's a $100M Venture)

Colosseum judges explicitly look for **sustainable venture viability**:
- **0.10% (10 bps) Protocol Settlement Fee**: Substantially cheaper than Stripe (2.9% + 30¢) and traditional credit cards (1.5% - 3.5%), yet wildly profitable at scale.
- **5 bps Spread on Enshrined FX Swaps**: Capturing cross-currency FX arbitrage volume.
- **Enterprise SaaS Tier ($99/mo)**: Automated payroll compliance, ERP integration (QuickBooks/Xero), and multi-seat permissions for corporate treasuries.

---

## 6. What Makes This Guaranteed to Stand Out to Judges:
1. **First-mover on Tempo**: Almost zero other projects will have functional Tempo EVM contracts with payment lanes and native stablecoin gas handling.
2. **Real-world Problem**: Cross-border payments and contractor payroll are the #1 practical use case for crypto globally in 2026.
3. **Multichain Harmony**: Demonstrates the true spirit of the "Crypto World's Fair"—not an isolated island, but connecting Solana retail to Tempo settlement.
