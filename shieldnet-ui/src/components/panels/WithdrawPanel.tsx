import { useState } from 'react'
import { ArrowUpFromLine, Shield, Loader2, AlertCircle, CheckCircle } from 'lucide-react'
import { parseUnits, formatUnits } from '../../lib/utils'

interface Props {
  wallet: { isConnected: boolean; address: string | null }
  shieldNet: {
    withdraw: (amount: bigint, recipient: string) => Promise<string>
    txState: { status: string; message: string; error?: string }
    getShieldedBalance: () => bigint
    getUnspentNotes: () => any[]
  }
}

export function WithdrawPanel({ wallet, shieldNet }: Props) {
  const [amount, setAmount] = useState('')
  const [recipient, setRecipient] = useState('')

  const handleWithdraw = async () => {
    if (!amount || !recipient) return
    await shieldNet.withdraw(parseUnits(amount, 18), recipient)
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
        <ArrowUpFromLine className="w-12 h-12 mx-auto mb-2 text-green-500" />
        <h2 className="text-xl font-bold text-white">Unshield Tokens</h2>
        <p className="text-slate-400 text-sm">Withdraw to a public address</p>
      </div>

      <div className="bg-slate-800 rounded-xl p-4">
        <div className="text-sm text-slate-400">Available</div>
        <div className="text-2xl font-bold text-green-400">
          {formatUnits(shieldNet.getShieldedBalance(), 18)} STRK
        </div>
        <div className="text-sm text-slate-500">{shieldNet.getUnspentNotes().length} notes</div>
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
        <label className="block text-sm text-slate-400 mb-2">Recipient Address</label>
        <input
          type="text"
          value={recipient}
          onChange={(e) => setRecipient(e.target.value)}
          placeholder="0x..."
          className="w-full bg-slate-800 border border-slate-600 rounded-xl px-4 py-3 font-mono text-sm text-white focus:outline-none focus:border-green-500"
        />
        <button onClick={() => setRecipient(wallet.address || '')} className="text-sm text-green-500 hover:text-green-400 mt-2">
          Use my address
        </button>
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
        onClick={handleWithdraw}
        disabled={!amount || !recipient || isLoading}
        className="w-full py-4 rounded-xl bg-green-600 hover:bg-green-500 disabled:bg-slate-700 disabled:text-slate-500 font-semibold text-white"
      >
        {isLoading ? <Loader2 className="w-5 h-5 animate-spin mx-auto" /> : 'Unshield Tokens'}
      </button>
    </div>
  )
}