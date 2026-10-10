# ⚡ TempoFlow (Internal Code: AegisPay)

> **The Sub-Second Programmable Stablecoin Highway: Cross-Chain Instant Settlement, Streaming Payroll & Enshrined FX on Tempo L1.**

[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-363636?logo=solidity)](https://soliditylang.org/)
[![Tempo L1](https://img.shields.io/badge/Network-Tempo%20L1%20Testnet-00D26A)](https://tempo.xyz)
[![Solana Anchor](https://img.shields.io/badge/Solana-Anchor%200.30-9945FF?logo=solana)](https://anchor-lang.com)
[![Tests](https://img.shields.io/badge/Tests-10%2F10%20Passing-brightgreen)](https://hardhat.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 🏆 Hackathon Tracks Targeted
1. **Tempo Ecosystem Track ($100,000)** (Primary)
2. **Payments & Stablecoins Track** (Global Category)
3. **Solana Ecosystem Track ($100,000)** (Cross-chain ingress & Blinks)
4. **Public Goods Track ($10,000)** (Open-source payment primitives)

---

## 🏛️ System Architecture

```
┌───────────────────────────────────────┐
│     Solana Retail Layer (Anchor)      │
│  • Payer deposits SPL-USDC into PDA   │
│  • Emits CrossChainPaymentIntent      │
└──────────────────┬────────────────────┘
                   │ Relayed via 20-byte EVM Address
                   ▼
┌───────────────────────────────────────────────────────────────┐
│                   Tempo L1 EVM Protocol                       │
│                                                               │
│  ┌────────────────────────┐      ┌─────────────────────────┐  │
│  │   TempoFlowRouter      │─────►│  Enshrined AMM (FX)     │  │
│  │ (10 bps fee + Replay)  │      │ (Consensus-level swaps) │  │
│  └───────────┬────────────┘      └────────────┬────────────┘  │
│              │                                │               │
│              ▼                                ▼               │
│  ┌────────────────────────┐      ┌─────────────────────────┐  │
│  │ MerchantSettlementVault│      │   TempoPayrollStream    │  │
│  │ (Non-custodial splits) │      │ (O(1) Continuous stream)│  │
│  └────────────────────────┘      └─────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quickstart & Verification

### 1. Run Automated Test Suites
```bash
npm install
npm test
```

**Output**:
```
  ⚡ TempoFlow Protocol Master Test Suite
    1. Merchant Settlement & FX Engine (TempoFlowRouter)
      ✔ TC-01: Instant Payment in Same Currency (USDC -> USDC minus 10 bps fee)
      ✔ TC-02: Instant Payment with Enshrined AMM FX Conversion (USDC -> EURC)
      ✔ TC-03: Order Replay Protection Prevents Double Spending
      ✔ TC-08: Split Payment Routing (80% Merchant, 20% Tax / Affiliate)
    2. Continuous Payroll Streaming Engine (TempoPayrollStream)
      ✔ TC-04: Continuous By-The-Second Payroll Accrual with Time Travel
      ✔ TC-05: Premature Cancellation & Exact Escrow Reconciliation
      ✔ TC-06: Security Check - Unauthorized Stream Withdrawal Reverts
    3. Non-Custodial Merchant Settlement Vault (MerchantSettlementVault)
      ✔ TC-07: Vault Multi-Token Deposit, Auto-Forwarding and Non-Custodial Withdrawal
    4. Security Guards, Emergency Circuit Breaker & Living Odometer (Audited)
      ✔ TC-09: Emergency Pause Blocks Payments & Non-Owner Cannot Pause
      ✔ TC-10: Stream Summary & Living Odometer State Verification

  10 passing (2s)
```

### 2. Deploy to Tempo L1 Testnet
```bash
npx hardhat run scripts/deploy.js --network tempoTestnet
```

---

## 🔒 Security & Mathematical Audits
- **Checks-Effects-Interactions (CEI)** pattern enforced across all token transfers.
- **Order Replay Prevention**: Keccak256 order hash registry ensures no duplicate fills.
- **$O(1)$ Time Complexity Linear Streaming**: Zero gas looping; mathematical interpolation allows by-the-second claims.
- **Emergency Circuit Breaker**: Owner-level pausing and unpausing safeguards.
- **Solana PDA Escrow & Timeout Refund**: 1-hour escrow expiration allows payer 100% refund guarantee.

---

## 📄 License
MIT License. Built for the **Crypto World's Fair** (Colosseum Arena Hackathon).
