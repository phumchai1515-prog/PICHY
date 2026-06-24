import { useState } from 'react'
import { useStore } from './store'
import Onboarding from './screens/Onboarding'
import CalendarScreen from './screens/CalendarScreen'
import WalletScreen from './screens/WalletScreen'
import SummaryScreen from './screens/SummaryScreen'
import ProfileScreen from './screens/ProfileScreen'
import TabBar, { type Tab } from './components/TabBar'

export default function App() {
  const hasOnboarded = useStore((s) => s.hasOnboarded)
  const [tab, setTab] = useState<Tab>('calendar')

  if (!hasOnboarded) {
    return (
      <div className="app-shell">
        <Onboarding />
      </div>
    )
  }

  return (
    <div className="app-shell">
      {tab === 'calendar' && <CalendarScreen />}
      {tab === 'wallet' && <WalletScreen />}
      {tab === 'summary' && <SummaryScreen />}
      {tab === 'profile' && <ProfileScreen />}
      <TabBar tab={tab} onChange={setTab} />
    </div>
  )
}
