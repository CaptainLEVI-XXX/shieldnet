import { ArrowDownToLine, ArrowUpFromLine, ArrowLeftRight, Zap, Wallet } from 'lucide-react'

type Tab = 'deposit' | 'withdraw' | 'transfer' | 'transact' | 'notes'

const tabs = [
  { id: 'deposit' as Tab, label: 'Shield', icon: ArrowDownToLine },
  { id: 'withdraw' as Tab, label: 'Unshield', icon: ArrowUpFromLine },
  { id: 'transfer' as Tab, label: 'Transfer', icon: ArrowLeftRight },
  { id: 'transact' as Tab, label: 'Transact', icon: Zap },
  { id: 'notes' as Tab, label: 'Notes', icon: Wallet },
]

interface Props {
  activeTab: Tab
  onTabChange: (tab: Tab) => void
}

export function Navigation({ activeTab, onTabChange }: Props) {
  return (
    <div className="flex gap-1 bg-slate-800 p-1 rounded-xl">
      {tabs.map((tab) => {
        const Icon = tab.icon
        const isActive = activeTab === tab.id
        return (
          <button
            key={tab.id}
            onClick={() => onTabChange(tab.id)}
            className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-lg font-medium transition ${
              isActive ? 'bg-green-600 text-white' : 'text-slate-400 hover:text-white hover:bg-slate-700'
            }`}
          >
            <Icon className="w-4 h-4" />
            <span className="hidden sm:inline">{tab.label}</span>
          </button>
        )
      })}
    </div>
  )
}