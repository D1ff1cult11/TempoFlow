import React, { useState } from 'react';
import { Navbar } from './components/Navbar';
import { JudgeBanner } from './components/JudgeBanner';
import { MerchantTerminal } from './components/MerchantTerminal';
import { PayrollOdometer } from './components/PayrollOdometer';
import { CrossChainRelay } from './components/CrossChainRelay';
import { SettlementModal } from './components/SettlementModal';
import { Store, Timer, ExternalLink, Github, BookOpen, Award } from 'lucide-react';

export default function App() {
  const [activeTab, setActiveTab] = useState('ALL'); // 'ALL' | 'MERCHANT' | 'PAYROLL'

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* 1. Header & Live Telemetry Navbar */}
      <Navbar />

      {/* 2. Top Sticky One-Click Judge Simulation Bar */}
      <JudgeBanner />

      {/* 3. Main Protocol Terminal Workspace */}
      <main style={{ maxWidth: '1280px', width: '100%', margin: '0 auto', padding: '24px', flex: 1 }}>
        {/* Hero Value Proposition Card */}
        <div style={{
          marginBottom: '28px',
          padding: '24px 28px',
          background: 'linear-gradient(135deg, rgba(15, 21, 32, 0.8) 0%, rgba(11, 15, 23, 0.9) 100%)',
          borderRadius: '16px',
          border: '1px solid var(--border-subtle)',
          boxShadow: '0 8px 32px rgba(0, 0, 0, 0.4)',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '16px' }}>
            <div>
              <div style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
                <span className="badge-pill badge-emerald">Tempo L1 Ecosystem</span>
                <span className="badge-pill badge-solana">Solana Retail Ingress</span>
                <span className="badge-pill badge-cyan">Colosseum World's Fair 2026</span>
              </div>
              <h1 style={{
                fontSize: 'clamp(1.5rem, 3.5vw, 2.2rem)',
                fontWeight: 800,
                fontFamily: 'var(--font-sans)',
                letterSpacing: '-0.02em',
                lineHeight: 1.2,
              }}>
                The Sub-Second Programmable Stablecoin Highway
              </h1>
              <p style={{
                fontSize: '0.92rem',
                color: 'var(--text-muted)',
                marginTop: '8px',
                maxWidth: '780px',
                lineHeight: 1.5,
              }}>
                Zero gas token friction. Settle retail merchant checkouts in <strong>0.6 seconds</strong> with <strong>10 bps fees</strong>, execute zero-slippage FX swaps at the validator layer, and stream continuous contractor salaries down to the exact second.
              </p>
            </div>

            {/* Quick Portal Switcher Tabs */}
            <div style={{ display: 'flex', gap: '8px' }}>
              <button
                onClick={() => setActiveTab('ALL')}
                className={activeTab === 'ALL' ? 'btn-primary' : 'btn-secondary'}
                style={{ fontSize: '0.85rem' }}
              >
                All Systems View
              </button>
              <button
                onClick={() => setActiveTab('MERCHANT')}
                className={activeTab === 'MERCHANT' ? 'btn-primary' : 'btn-secondary'}
                style={{ fontSize: '0.85rem' }}
              >
                <Store size={15} />
                Merchant POS
              </button>
              <button
                onClick={() => setActiveTab('PAYROLL')}
                className={activeTab === 'PAYROLL' ? 'btn-primary' : 'btn-secondary'}
                style={{ fontSize: '0.85rem' }}
              >
                <Timer size={15} />
                Payroll Odometer
              </button>
            </div>
          </div>
        </div>

        {/* 4. Cross-Chain Telemetry Pipeline Visualizer */}
        <CrossChainRelay />

        {/* 5. Core Portals Grid */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '28px' }}>
          {(activeTab === 'ALL' || activeTab === 'MERCHANT') && (
            <section>
              <MerchantTerminal />
            </section>
          )}

          {(activeTab === 'ALL' || activeTab === 'PAYROLL') && (
            <section>
              <PayrollOdometer />
            </section>
          )}
        </div>
      </main>

      {/* 6. Cryptographic Settlement Receipt Modal */}
      <SettlementModal />

      {/* 7. Footer */}
      <footer style={{
        borderTop: '1px solid var(--border-subtle)',
        background: 'rgba(6, 8, 13, 0.95)',
        padding: '24px',
        marginTop: '40px',
        fontSize: '0.82rem',
        color: 'var(--text-dim)',
      }}>
        <div style={{
          maxWidth: '1280px',
          margin: '0 auto',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          flexWrap: 'wrap',
          gap: '16px',
        }}>
          <div>
            <strong>TempoFlow Protocol</strong> • Built for the Colosseum Crypto World's Fair (Fall 2026)
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
            <a
              href="https://github.com/D1ff1cult11/TempoFlow"
              target="_blank"
              rel="noreferrer"
              style={{ color: 'var(--text-muted)', textDecoration: 'none', display: 'flex', alignItems: 'center', gap: '6px' }}
            >
              <Github size={15} />
              GitHub Repository
            </a>
            <span style={{ color: 'var(--tempo-emerald)' }}>
              MIT Licensed Public Good
            </span>
          </div>
        </div>
      </footer>
    </div>
  );
}
