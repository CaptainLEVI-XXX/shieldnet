import { useState } from 'react'
import { Shield, Loader2, CheckCircle, AlertCircle } from 'lucide-react'
import { parseUnits, formatUnits } from '../../lib/utils'

interface Props {
  wallet: { isConnected: boolean }
  shieldNet: {
    deposit: (amount: bigint) => Promise<any>
    txState: { status: string; message: string }
    getShieldedBalance: () => bigint
  }
}

export function DepositPanel({ wallet, shieldNet }: Props) {
  const [amount, setAmount] = useState('')

  const handleDeposit = async () => {
    if (!amount) return
    try {
      await shieldNet.deposit(parseUnits(amount, 18))
      setAmount('')
    } catch (e) {
      console.error(e)
    }
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

  return (
    <div className="space-y-6">
      <div className="text-center">
        <Shield className="w-12 h-12 mx-auto mb-2 text-green-500" />
        <h2 className="text-xl font-bold text-white">Shield Tokens</h2>
        <p className="text-slate-400 text-sm">Deposit STRK into the privacy pool</p>
      </div>

      <div className="bg-slate-800 rounded-xl p-4">
        <div className="text-sm text-slate-400">Shielded Balance</div>
        <div className="text-2xl font-bold text-green-400">
          {formatUnits(shieldNet.getShieldedBalance(), 18)} STRK
        </div>
      </div>

      <div>
        <label className="block text-sm text-slate-400 mb-2">Amount</label>
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="0.0"
          className="w-full bg-slate-800 border border-slate-600 rounded-xl px-4 py-3 text-lg text-white focus:outline-none focus:border-green-500"
        />
      </div>

      {txState.status !== 'idle' && (
        <div className={`flex items-center gap-3 p-4 rounded-xl ${
          txState.status === 'error' ? 'bg-red-500/10 text-red-400' :
          txState.status === 'confirmed' ? 'bg-green-500/10 text-green-400' :
          'bg-slate-800 text-white'
        }`}>
          {txState.status === 'error' ? <AlertCircle className="w-5 h-5" /> :
           txState.status === 'confirmed' ? <CheckCircle className="w-5 h-5" /> :
           <Loader2 className="w-5 h-5 animate-spin" />}
          <span>{txState.message}</span>
        </div>
      )}

      <button
        onClick={handleDeposit}
        disabled={!amount || txState.status === 'approving' || txState.status === 'submitting'}
        className="w-full py-4 rounded-xl bg-green-600 hover:bg-green-500 disabled:bg-slate-700 disabled:text-slate-500 font-semibold text-white"
      >
        {txState.status === 'approving' || txState.status === 'submitting' ? (
          <span className="flex items-center justify-center gap-2">
            <Loader2 className="w-5 h-5 animate-spin" />
            {txState.message}
          </span>
        ) : (
          'Shield Tokens'
        )}
      </button>
    </div>
  )
}