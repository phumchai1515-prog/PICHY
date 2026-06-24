export type Tab = 'calendar' | 'wallet' | 'summary' | 'profile'

const TABS: { id: Tab; icon: string; label: string }[] = [
  { id: 'calendar', icon: '📅', label: 'ปฏิทิน' },
  { id: 'wallet', icon: '💳', label: 'รายรับจ่าย' },
  { id: 'summary', icon: '📊', label: 'สรุป' },
  { id: 'profile', icon: '👤', label: 'โปรไฟล์' },
]

export default function TabBar({ tab, onChange }: { tab: Tab; onChange: (t: Tab) => void }) {
  return (
    <nav className="tab-bar">
      {TABS.map((t) => (
        <button key={t.id} className={`tab-item${tab === t.id ? ' active' : ''}`} onClick={() => onChange(t.id)}>
          <span className="ic">{t.icon}</span>
          <span>{t.label}</span>
        </button>
      ))}
    </nav>
  )
}
