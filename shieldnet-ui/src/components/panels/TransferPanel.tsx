import { useState } from 'react'
import { ArrowLeftRight, Shield } from 'lucide-react'
import { formatUnits } from '../../lib/utils'

interface Props {
  wallet: { isConnected: boolean }
  shieldNet: { getShieldedBalance: () => bigint }
}

export function TransferPanel({ wallet, shieldNet }: Props) {
  const [amount, setAmount] = useState('')
  const [recipientKey, setRecipientKey] = useState('')

  if (!wallet.isConnected) {
    return (
      <div className="text-center py-12">
        <Shield className="w-16 h-16 mx-auto mb-4 text-slate-600" />
        <p className="text-slate-400">Connect wallet to continue</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="text-center">
        <ArrowLeftRight className="w-12 h-12 mx-auto mb-2 text-green-500" />
        <h2 className="text-xl font-bold text-white">Private Transfer</h2>
        <p className="text-slate-400 text-sm">Send privately to another user</p>
      </div>

      <div className="bg-slate-800 rounded-xl p-4">
        <div className="text-sm text-slate-400">Available</div>
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
          className="w-full bg-slate-800 border border-slate-600 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-green-500"
        />
      </div>

      <div>
        <label className="block text-sm text-slate-400 mb-2">Recipient Public Key</label>
        <input
          type="text"
          value={recipientKey}
          onChange={(e) => setRecipientKey(e.target.value)}
          placeholder="0x..."
          className="w-full bg-slate-800 border border-slate-600 rounded-xl px-4 py-3 font-mono text-sm text-white focus:outline-none focus:border-green-500"
        />
      </div>

      <button
        disabled={!amount || !recipientKey}
        className="w-full py-4 rounded-xl bg-green-600 hover:bg-green-500 disabled:bg-slate-700 disabled:text-slate-500 font-semibold text-white"
      >
        Transfer Privately
      </button>
    </div>
  )
}