import { useState } from 'react'
import { Zap, Shield, ArrowRight, Loader2, AlertCircle, CheckCircle } from 'lucide-react'
import { parseUnits, formatUnits } from '../../lib/utils'

interface Props {
  wallet: { isConnected: boolean }
  shieldNet: {
    transact: (amount: bigint, target: string, calldata: string[], minOutput: bigint) => Promise<string>
    txState: { status: string; message: string; error?: string }
    getShieldedBalance: () => bigint
  }
}

export function TransactPanel({ wallet, shieldNet }: Props) {
  const [amount, setAmount] = useState('')
  const [target, setTarget] = useState('')
  const [minOutput, setMinOutput] = useState('')

  const handleTransact = async () => {
    if (!amount || !target) return
    await shieldNet.transact(
      parseUnits(amount, 18),
      target,
      [], // Empty calldata for now
      parseUnits(minOutput || '0', 18)
    )
    setAmount('')
  }

  if (!wallet.isConnected) {
    return (
      <div className="text-center py-12">
        <Shield className="w-16 h-16 mx-auto mb-4 text-slate-600" />
        <p className="text-slate-400">Connect wallet to continue</p>
      </div>
    )
  }

  const { txState } = shieldNet
  const isLoading = ['generating_witness', 'generating_proof', 'preparing_calldata', 'submitting'].includes(txState.status)

  return (
    <div className="space-y-6">
      <div className="text-center">
        <Zap className="w-12 h-12 mx-auto mb-2 text-green-500" />
        <h2 className="text-xl font-bold text-white">Private DeFi</h2>
        <p className="text-slate-400 text-sm">Interact with any protocol privately</p>
      </div>

      <div className="flex items-center justify-center gap-2 text-sm bg-slate-800 rounded-xl p-3">
        <span className="text-green-400">Private</span>
        <ArrowRight className="w-4 h-4 text-slate-500" />
        <span className="text-yellow-400">DeFi</span>
        <ArrowRight className="w-4 h-4 text-slate-500" />
        <span className="text-green-400">Private</span>
      </div>

      <div className="bg-slate-800 rounded-xl p-4">
        <div className="text-sm text-slate-400">Available</div>
        <div className="text-2xl font-bold text-green-400">
          {formatUnits(shieldNet.getShieldedBalance(), 18)} STRK
        </div>
      </div>

      <div>
        <label className="block text-sm text-slate-400 mb-2">Input Amount</label>
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="0.0"
          className="w-full bg-slate-800 border border-slate-600 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-green-500"
        />
      </div>

      <div>
        <label className="block text-sm text-slate-400 mb-2">Target Contract</label>
        <input
          type="text"
          value={target}
          onChange={(e) => setTarget(e.target.value)}
          placeholder="0x..."
          className="w-full bg-slate-800 border border-slate-600 rounded-xl px-4 py-3 font-mono text-sm text-white focus:outline-none focus:border-green-500"
        />
      </div>

      <div>
        <label className="block text-sm text-slate-400 mb-2">Min Output (slippage protection)</label>
        <input
          type="number"
          value={minOutput}
          onChange={(e) => setMinOutput(e.target.value)}
          placeholder="0.0"
          className="w-full bg-slate-800 border border-slate-600 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-green-500"
        />
      </div>

      {txState.status !== 'idle' && (
        <div className={`flex items-center gap-3 p-4 rounded-xl ${
          txState.status === 'error' ? 'bg-red-500/10 text-red-400' :
          txState.status === 'confirmed' ? 'bg-green-500/10 text-green-400' :
          'bg-slate-800 text-white'
        }`}>
          {txState.status === 'error' && <AlertCircle className="w-5 h-5" />}
          {txState.status === 'confirmed' && <CheckCircle className="w-5 h-5" />}
          {isLoading && <Loader2 className="w-5 h-5 animate-spin" />}
          <span>{txState.message}</span>
        </div>
      )}

      <button
        onClick={handleTransact}
        disabled={!amount || !target || isLoading}
        className="w-full py-4 rounded-xl bg-green-600 hover:bg-green-500 disabled:bg-slate-700 disabled:text-slate-500 font-semibold text-white"
      >
        {isLoading ? <Loader2 className="w-5 h-5 animate-spin mx-auto" /> : 'Execute Private DeFi'}
      </button>

      <p className="text-sm text-yellow-400/80 text-center">
        ⚠️ Permissionless: You choose the protocol
      </p>
    </div>
  )
}