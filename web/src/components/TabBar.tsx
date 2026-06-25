import { Calendar, Wallet, BarChart3, User, type LucideIcon } from 'lucide-react'

export type Tab = 'calendar' | 'wallet' | 'summary' | 'profile'

const TABS: { id: Tab; icon: LucideIcon; label: string }[] = [
  { id: 'calendar', icon: Calendar, label: 'ปฏิทิน' },
  { id: 'wallet', icon: Wallet, label: 'รายรับจ่าย' },
  { id: 'summary', icon: BarChart3, label: 'สรุป' },
  { id: 'profile', icon: User, label: 'โปรไฟล์' },
]

export default function TabBar({ tab, onChange }: { tab: Tab; onChange: (t: Tab) => void }) {
  return (
    <nav className="tab-bar">
      {TABS.map((t) => {
        const Icon = t.icon
        return (
          <button key={t.id} className={`tab-item${tab === t.id ? ' active' : ''}`} onClick={() => onChange(t.id)}>
            <Icon className="ic" size={22} strokeWidth={tab === t.id ? 2.4 : 2} />
            <span>{t.label}</span>
          </button>
        )
      })}
    </nav>
  )
}
