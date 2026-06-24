import { useMemo, useState } from 'react'
import { useStore } from '../store'
import { shiftsOn, shiftsInMonth, shiftCountsInMonth, monthlyIncome } from '../selectors'
import { SHIFT_META } from '../meta'
import { resolvedLeave } from '../domain'
import { LEAVE_META } from '../meta'
import { baht } from '../utils/money'
import { WEEKDAY_HEADERS, monthCells, monthYearLong, addMonths, todayKey, toKey, greeting } from '../utils/thaiDate'
import DayDetailSheet from './DayDetailSheet'
import AddShiftSheet from './AddShiftSheet'
import { MascotHead } from '../components/Mascot'

export default function CalendarScreen() {
  const { shifts, transactions, rates, profile } = useStore()
  const [month, setMonth] = useState(() => new Date(new Date().getFullYear(), new Date().getMonth(), 1))
  const [selected, setSelected] = useState<string | null>(null)
  const [quickAdd, setQuickAdd] = useState(false)
  const today = todayKey()
  const monthKey = toKey(month)

  const cells = useMemo(() => monthCells(month), [month])
  const counts = shiftCountsInMonth(shifts, monthKey)
  const workCount = shiftsInMonth(shifts, monthKey).filter((s) => s.type !== 'off').length
  const income = monthlyIncome(shifts, transactions, rates, monthKey)

  return (
    <div className="screen">
      <div className="between" style={{ marginBottom: 16 }}>
        <div className="col">
          <span className="tiny muted">{greeting()}</span>
          <span className="h2">{profile.name || 'คุณพยาบาล'}</span>
        </div>
        <MascotHead size={48} />
      </div>

      <div className="card" style={{ padding: 16, marginBottom: 16 }}>
        <div className="between">
          <button className="press" onClick={() => setMonth(addMonths(month, -1))} style={{ fontSize: 20, color: 'var(--peach-active)' }}>‹</button>
          <span style={{ fontWeight: 700, fontSize: 16 }}>{monthYearLong(month)}</span>
          <button className="press" onClick={() => setMonth(addMonths(month, 1))} style={{ fontSize: 20, color: 'var(--peach-active)' }}>›</button>
        </div>
        <div className="between" style={{ marginTop: 10 }}>
          <span className="tiny muted">{workCount} เวร</span>
          <span className="small" style={{ fontWeight: 700, color: 'var(--income-green)' }}>{baht(income)}</span>
        </div>
      </div>

      <div className="card" style={{ padding: 12, marginBottom: 16 }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, minmax(0, 1fr))', gap: 5, marginBottom: 6 }}>
          {WEEKDAY_HEADERS.map((w, i) => (
            <div key={i} className="tiny" style={{ textAlign: 'center', fontWeight: 600, color: i === 0 ? 'var(--peach-active)' : 'var(--text-muted)' }}>{w}</div>
          ))}
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, minmax(0, 1fr))', gap: 5 }}>
          {cells.map((key, i) => key ? (
            <DayCell key={i} dayKey={key} isToday={key === today} shifts={shiftsOn(shifts, key)} onTap={() => setSelected(key)} />
          ) : <div key={i} />)}
        </div>
      </div>

      <div className="card" style={{ padding: 12 }}>
        <div className="row" style={{ flexWrap: 'wrap', gap: 8, justifyContent: 'center' }}>
          {(['morning', 'afternoon', 'night', 'ot'] as const).map((t) => (
            <span key={t} className="chip" style={{ background: SHIFT_META[t].tint, color: SHIFT_META[t].text }}>
              <i style={{ width: 8, height: 8, borderRadius: 8, background: SHIFT_META[t].dot, display: 'inline-block' }} /> {SHIFT_META[t].label} {counts[t]}
            </span>
          ))}
        </div>
      </div>

      <button className="fab press" onClick={() => setQuickAdd(true)}>＋</button>

      {selected && <DayDetailSheet date={selected} onClose={() => setSelected(null)} />}
      {quickAdd && <AddShiftSheet date={today} onClose={() => setQuickAdd(false)} />}
    </div>
  )
}

function DayCell({ dayKey, isToday, shifts, onTap }: { dayKey: string; isToday: boolean; shifts: ReturnType<typeof shiftsOn>; onTap: () => void }) {
  const day = Number(dayKey.slice(8))
  const work = shifts.filter((s) => s.type !== 'off')
  const leave = shifts.find((s) => s.type === 'off')
  const leaveKind = leave && resolvedLeave(leave)
  const hasOT = shifts.some((s) => s.otHours > 0)
  const bg = work.length ? SHIFT_META[work[0].type].tint : leaveKind ? LEAVE_META[leaveKind].tint : 'transparent'

  return (
    <button className="press" onClick={onTap}
      style={{ height: 46, borderRadius: 12, background: bg, position: 'relative', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 2, overflow: 'hidden' }}>
      <span style={{ fontSize: 13, fontWeight: 600, color: isToday ? 'var(--peach-active)' : 'var(--text-primary)' }}>{day}</span>
      {work.length > 0 ? (
        <span style={{ display: 'flex', gap: 3 }}>
          {work.slice(0, 2).map((s, i) => (
            <span key={i} className="tiny" style={{ fontWeight: 700, fontSize: 9, color: SHIFT_META[s.type].text }}>{SHIFT_META[s.type].shortChip}</span>
          ))}
        </span>
      ) : leaveKind ? (
        <span className="tiny" style={{ fontSize: 9, fontWeight: 700, color: LEAVE_META[leaveKind].color, whiteSpace: 'nowrap', maxWidth: '100%', overflow: 'hidden', textOverflow: 'clip' }}>{LEAVE_META[leaveKind].shortLabel}</span>
      ) : null}
      {hasOT && <span style={{ position: 'absolute', top: 4, right: 5, width: 7, height: 7, borderRadius: 7, background: SHIFT_META.ot.dot }} />}
      {isToday && <span style={{ position: 'absolute', bottom: 3, width: 4, height: 4, borderRadius: 4, background: 'var(--peach-active)' }} />}
    </button>
  )
}
