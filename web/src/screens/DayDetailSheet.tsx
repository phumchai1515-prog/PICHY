import { useState } from 'react'
import Sheet from '../components/Sheet'
import { useStore } from '../store'
import { shiftsOn, activitiesOn } from '../selectors'
import { SHIFT_META, LEAVE_META, ACTIVITY_META } from '../meta'
import { shiftIncome, resolvedLeave } from '../domain'
import { baht } from '../utils/money'
import { fullDate } from '../utils/thaiDate'
import type { Shift } from '../types'
import AddShiftSheet from './AddShiftSheet'
import AddActivitySheet from './AddActivitySheet'

export default function DayDetailSheet({ date, onClose }: { date: string; onClose: () => void }) {
  const { shifts, activities, rates, deleteActivity } = useStore()
  const dayShifts = shiftsOn(shifts, date)
  const dayActs = activitiesOn(activities, date)
  const income = dayShifts.reduce((s, sh) => s + shiftIncome(sh, rates), 0)

  const [addShift, setAddShift] = useState(false)
  const [editShift, setEditShift] = useState<Shift | null>(null)
  const [addAct, setAddAct] = useState(false)

  return (
    <Sheet onClose={onClose}>
      <div className="hero" style={{ marginBottom: 16 }}>
        <div style={{ fontSize: 20, fontWeight: 600 }}>{fullDate(date)}</div>
        {income > 0 && <div className="small" style={{ opacity: 0.9, marginTop: 4 }}>รายได้รวมวันนี้ {baht(income)}</div>}
      </div>

      <div className="between" style={{ marginBottom: 8 }}>
        <span className="small secondary" style={{ fontWeight: 600 }}>เวร ({dayShifts.length})</span>
      </div>
      <div className="card" style={{ overflow: 'hidden' }}>
        {dayShifts.length === 0 ? (
          <div className="muted small" style={{ padding: 16 }}>ยังไม่มีเวรในวันนี้</div>
        ) : dayShifts.map((sh, i) => {
          const leave = resolvedLeave(sh)
          const m = SHIFT_META[sh.type]
          return (
            <div key={sh.id}>
              <button className="row press" style={{ width: '100%', padding: 12, textAlign: 'left' }} onClick={() => setEditShift(sh)}>
                {leave ? (
                  (() => { const LeaveIcon = LEAVE_META[leave].icon; return (
                    <div className="square-chip" style={{ background: LEAVE_META[leave].tint, color: LEAVE_META[leave].color }}><LeaveIcon size={18} /></div>
                  ) })()
                ) : (
                  <div className="square-chip" style={{ background: m.tint, color: m.text }}>{m.shortChip}</div>
                )}
                <div className="grow col" style={{ gap: 2 }}>
                  <span className="small" style={{ fontWeight: 600 }}>
                    {leave ? LEAVE_META[leave].label : `เวร${m.label}`}{sh.otHours > 0 ? ` + OT ${sh.otHours} ชม.` : ''}
                  </span>
                  <span className="tiny muted">{m.timeRange}</span>
                </div>
                {!leave && <span style={{ fontWeight: 700, color: 'var(--income-green)' }}>{baht(shiftIncome(sh, rates))}</span>}
              </button>
              {i < dayShifts.length - 1 && <div className="divider" style={{ marginLeft: 60 }} />}
            </div>
          )
        })}
      </div>
      <AddBtn label="เพิ่มเวร" onClick={() => setAddShift(true)} />

      <div className="between" style={{ margin: '16px 0 8px' }}>
        <span className="small secondary" style={{ fontWeight: 600 }}>กิจกรรม ({dayActs.length})</span>
      </div>
      <div className="card" style={{ overflow: 'hidden' }}>
        {dayActs.length === 0 ? (
          <div className="muted small" style={{ padding: 16 }}>ยังไม่มีกิจกรรมในวันนี้</div>
        ) : dayActs.map((a, i) => {
          const m = ACTIVITY_META[a.category]
          const ActIcon = m.icon
          return (
            <div key={a.id}>
              <div className="row" style={{ padding: 12 }}>
                <div className="square-chip" style={{ background: m.tint, color: m.color }}><ActIcon size={18} /></div>
                <div className="grow col" style={{ gap: 2 }}>
                  <span className="small" style={{ fontWeight: 600 }}>{a.title}</span>
                  {a.note && <span className="tiny muted">{a.note}</span>}
                </div>
                <span className="small" style={{ fontWeight: 600, color: m.color }}>{a.time}</span>
                <button className="press" onClick={() => deleteActivity(a.id)} style={{ color: 'var(--text-muted)', padding: 4 }}>✕</button>
              </div>
              {i < dayActs.length - 1 && <div className="divider" style={{ marginLeft: 60 }} />}
            </div>
          )
        })}
      </div>
      <AddBtn label="เพิ่มกิจกรรม" onClick={() => setAddAct(true)} />

      {addShift && <AddShiftSheet date={date} onClose={() => setAddShift(false)} />}
      {editShift && <AddShiftSheet date={date} editing={editShift} onClose={() => setEditShift(null)} />}
      {addAct && <AddActivitySheet date={date} onClose={() => setAddAct(false)} />}
    </Sheet>
  )
}

function AddBtn({ label, onClick }: { label: string; onClick: () => void }) {
  return (
    <button className="press" onClick={onClick}
      style={{ width: '100%', marginTop: 10, padding: 12, borderRadius: 14, background: 'var(--surface-peach)', color: 'var(--peach-active)', fontWeight: 600 }}>
      ＋ {label}
    </button>
  )
}
