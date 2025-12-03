import { Shield, Wallet, LogOut } from 'lucide-react'
import { truncateAddress } from '../lib/utils'

interface Props {
  wallet: {
    address: string | null
    isConnected: boolean
    connect: () => Promise<any>
    disconnect: () => Promise<void>
  }
}

export function Header({ wallet }: Props) {
  return (
    <header className="border-b border-slate-700 bg-slate-900/80 backdrop-blur">
      <div className="container mx-auto px-4 py-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Shield className="w-8 h-8 text-green-500" />
          <span className="text-xl font-bold text-white">ShieldNet</span>
        </div>

        {wallet.isConnected && wallet.address ? (
          <div className="flex items-center gap-3">
            <div className="px-3 py-2 rounded-lg bg-slate-800 text-sm font-mono text-white">
              {truncateAddress(wallet.address)}
            </div>
            <button onClick={wallet.disconnect} className="p-2 rounded-lg bg-slate-800 hover:bg-slate-700 text-white">
              <LogOut className="w-5 h-5" />
            </button>
          </div>
        ) : (
          <button onClick={wallet.connect} className="flex items-center gap-2 px-4 py-2 rounded-lg bg-green-600 hover:bg-green-500 font-medium text-white">
            <Wallet className="w-5 h-5" />
            Connect
          </button>
        )}
      </div>
    </header>
  )
}