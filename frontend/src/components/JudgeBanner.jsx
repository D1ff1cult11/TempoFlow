import React from 'react';
import { useTempoStore } from '../store/useTempoStore';
import { Sparkles, FastForward, ArrowRightLeft, Send, CheckCircle2 } from 'lucide-react';

export function JudgeBanner() {
  const {
    isJudgeMode,
    simulateSolanaPayment,
    simulateTimeWarp,
    simulateFXSwap,
    relayerStep,
  } = useTempoStore();

  if (!isJudgeMode) {
    return (
      <div style={{
        background: 'rgba(0, 240, 255, 0.08)',
        borderBottom: '1px solid rgba(0, 240, 255, 0.25)',
        padding: '10px 24px',
        textAlign: 'center',
        fontSize: '0.85rem',
        color: 'var(--tempo-cyan)',
        fontFamily: 'var(--font-sans)',
      }}>
        ⚡ <strong>Live Web3 Mode Active</strong>: Connected to Tempo L1 Testnet (ChainId 4242) and Solana Devnet. You can mint testnet stablecoins and sign real on-chain transactions directly!
      </div>
    );
  }

  return (
    <div style={{
      background: 'linear-gradient(90deg, rgba(0, 210, 106, 0.12) 0%, rgba(0, 240, 255, 0.1) 50%, rgba(153, 69, 255, 0.12) 100%)',
      borderBottom: '1px solid rgba(0, 210, 106, 0.3)',
      padding: '12px 24px',
      boxShadow: '0 4px 20px rgba(0, 0, 0, 0.3)',
    }}>
      <div style={{
        maxWidth: '1280px',
        margin: '0 auto',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        flexWrap: 'wrap',
        gap: '12px',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{
            width: '28px',
            height: '28px',
            borderRadius: '50%',
            background: 'var(--tempo-emerald)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#06080D',
          }}>
            <Sparkles size={16} />
          </div>
          <div>
            <div style={{ fontSize: '0.9rem', fontWeight: 700, color: '#FFFFFF', fontFamily: 'var(--font-sans)' }}>
              ⭐ One-Click Judge Simulation Bar
            </div>
            <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
              Test sub-second settlement, continuous time-travel, and consensus FX with zero wallet/faucet friction:
            </div>
          </div>
        </div>

        {/* 3 Instant Action Triggers */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
          <button
            onClick={() => simulateSolanaPayment(50.0)}
            disabled={relayerStep !== 'IDLE'}
            className="btn-action-solana"
            style={{ fontSize: '0.82rem', padding: '8px 14px' }}
          >
            <Send size={14} />
            {relayerStep === 'IDLE' ? '1. Simulate $50 Solana Pay' : 'Processing Settlement...'}
          </button>

          <button
            onClick={() => simulateTimeWarp(24)}
            className="btn-secondary"
            style={{
              fontSize: '0.82rem',
              padding: '8px 14px',
              borderColor: 'rgba(0, 240, 255, 0.3)',
              color: 'var(--tempo-cyan)',
            }}
          >
            <FastForward size={14} />
            2. Fast-Forward 24H Payroll
          </button>

          <button
            onClick={() => simulateFXSwap(100.0)}
            className="btn-secondary"
            style={{
              fontSize: '0.82rem',
              padding: '8px 14px',
              borderColor: 'rgba(0, 210, 106, 0.3)',
              color: 'var(--tempo-emerald)',
            }}
          >
            <ArrowRightLeft size={14} />
            3. Simulate Enshrined FX (USDC→EURC)
          </button>
        </div>
      </div>
    </div>
  );
}
