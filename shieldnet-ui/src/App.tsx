import { useState, useEffect } from 'react'
import { useWallet } from './hooks/useWallet'
import { useShieldNet } from './hooks/useShieldNet'
import { Header } from './components/Header'
import { Navigation } from './components/Navigation'
import { DepositPanel } from './components/panels/DepositPanel'
import { WithdrawPanel } from './components/panels/WithdrawPanel'
import { TransferPanel } from './components/panels/TransferPanel'
import { TransactPanel } from './components/panels/TransactPanel'
import { NotesPanel } from './components/panels/NotesPanel'
import { initCircuits } from './lib/proof'

type Tab = 'deposit' | 'withdraw' | 'transfer' | 'transact' | 'notes'

function App() {
  const [activeTab, setActiveTab] = useState<Tab>('deposit')
  const wallet = useWallet()
  const shieldNet = useShieldNet(wallet.account)

  useEffect(() => {
    initCircuits()
  }, [])

  const renderPanel = () => {
    const props = { wallet, shieldNet }
    switch (activeTab) {
      case 'deposit': return <DepositPanel {...props} />
      case 'withdraw': return <WithdrawPanel {...props} />
      case 'transfer': return <TransferPanel {...props} />
      case 'transact': return <TransactPanel {...props} />
      case 'notes': return <NotesPanel {...props} />
    }
  }

  return (
    <div className="min-h-screen bg-slate-900">
      <div className="fixed inset-0 bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 -z-10" />
      <div className="fixed top-0 left-1/2 -translate-x-1/2 w-[600px] h-[400px] bg-green-500/10 rounded-full blur-3xl -z-10" />

      <Header wallet={wallet} />

      <main className="container mx-auto px-4 py-8 max-w-2xl">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold mb-2">
            <span className="gradient-text">ShieldNet</span>
          </h1>
          <p className="text-slate-400">Private transactions on Starknet</p>
        </div>

        <Navigation activeTab={activeTab} onTabChange={setActiveTab} />

        <div className="glass rounded-2xl p-6 mt-6">
          {renderPanel()}
        </div>

        <p className="text-center text-slate-500 text-sm mt-6">
          Starknet Sepolia • STRK Token
        </p>
      </main>
    </div>
  )
}

export default App