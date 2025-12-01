import { useState } from 'react'
import { Wallet, Shield, Copy, Check, Key } from 'lucide-react'
import { formatUnits } from '../../lib/utils'

interface Props {
  wallet: { isConnected: boolean }
  shieldNet: {
    publicKey: bigint
    notes: any[]
    getShieldedBalance: () => bigint
    getUnspentNotes: () => any[]
  }
}

export function NotesPanel({ wallet, shieldNet }: Props) {
  const [copied, setCopied] = useState(false)

  const copyKey = () => {
    navigator.clipboard.writeText('0x' + shieldNet.publicKey.toString(16))
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  if (!wallet.isConnected) {
    return (
      <div className="text-center py-12">
        <Shield className="w-16 h-16 mx-auto mb-4 text-slate-600" />
        <p className="text-slate-400">Connect wallet to continue</p>
      </div>
    )
  }

  const unspent = shieldNet.getUnspentNotes()

  return (
    <div className="space-y-6">
      <div className="text-center">
        <Wallet className="w-12 h-12 mx-auto mb-2 text-green-500" />
        <h2 className="text-xl font-bold text-white">Your Notes</h2>
      </div>

      <div className="bg-slate-800 rounded-xl p-4">
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2 text-sm text-slate-400">
            <Key className="w-4 h-4" />
            Your Public Key
          </div>
          <button onClick={copyKey} className="text-green-500 hover:text-green-400">
            {copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
          </button>
        </div>
        <div className="font-mono text-xs bg-slate-900 rounded p-2 break-all text-slate-300">
          0x{shieldNet.publicKey.toString(16).slice(0, 20)}...
        </div>
      </div>

      <div className="bg-gradient-to-r from-green-600/20 to-green-500/10 rounded-xl p-6 border border-green-500/30">
        <div className="text-sm text-green-300">Total Shielded</div>
        <div className="text-3xl font-bold text-white">{formatUnits(shieldNet.getShieldedBalance(), 18)} STRK</div>
      </div>

      <div>
        <h3 className="font-semibold mb-3 text-white">Notes ({unspent.length} unspent)</h3>
        {shieldNet.notes.length === 0 ? (
          <div className="text-center py-8 bg-slate-800 rounded-xl text-slate-400">
            No notes yet
          </div>
        ) : (
          <div className="space-y-2">
            {shieldNet.notes.map((note, i) => (
              <div
                key={i}
                className={`p-4 rounded-xl border ${
                  note.spent ? 'bg-slate-900 border-slate-700 opacity-50' : 'bg-slate-800 border-slate-600'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-semibold text-white">{formatUnits(note.amount, 18)} STRK</span>
                  <span className={`text-xs px-2 py-1 rounded ${
                    note.spent ? 'bg-red-500/20 text-red-400' : 'bg-green-500/20 text-green-400'
                  }`}>
                    {note.spent ? 'Spent' : 'Available'}
                  </span>
                </div>
                <div className="text-xs text-slate-500 mt-1">
                  {new Date(note.createdAt).toLocaleString()}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <p className="text-sm text-yellow-400/80 text-center">
        ⚠️ Notes stored in browser. Back up your data!
      </p>
    </div>
  )
}
