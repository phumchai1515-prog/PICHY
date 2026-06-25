import { useState } from 'react'
import Sheet from '../components/Sheet'
import { useStore } from '../store'
import { SHIFT_META, LEAVE_META } from '../meta'
import type { Shift, ShiftType, LeaveType } from '../types'
import { shiftIncome, uid, resolvedLeave } from '../domain'
import { baht } from '../utils/money'
import { fullDate } from '../utils/thaiDate'

const TYPES: ShiftType[] = ['morning', 'afternoon', 'night', 'ot', 'off', 'custom']
const LEAVES: LeaveType[] = ['dayOff', 'publicHoliday', 'sick', 'personal', 'vacation']

export default function AddShiftSheet({ date, editing, onClose }: { date: string; editing?: Shift; onClose: () => void }) {
  const { upsertShift, deleteShift, setLeaveRange, rates } = useStore()
  const [type, setType] = useState<ShiftType>(editing?.type ?? 'morning')
  const [otOn, setOtOn] = useState((editing?.otHours ?? 0) > 0)
  const [otHours, setOtHours] = useState(editing?.otHours || 2)
  const [leave, setLeave] = useState<LeaveType>((editing && resolvedLeave(editing)) || 'dayOff')

  const isLeave = type === 'off'
  const previewShift: Shift = { id: 'preview', date, type, otHours: !isLeave && otOn ? otHours : 0 }
  const income = shiftIncome(previewShift, rates)

  function save() {
    const shift: Shift = {
      id: editing?.id ?? uid(),
      date,
      type,
      otHours: isLeave ? 0 : otOn ? otHours : 0,
      leaveType: isLeave ? leave : undefined,
    }
    upsertShift(shift)
    onClose()
  }

  return (
    <Sheet onClose={onClose}>
      <h2 className="h2" style={{ marginBottom: 4 }}>{editing ? 'แก้ไขเวร' : 'เพิ่มเวร'}</h2>
      <p className="muted tiny" style={{ marginTop: 0 }}>{fullDate(date)}</p>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, marginTop: 8 }}>
        {TYPES.map((t) => {
          const m = SHIFT_META[t]
          const on = type === t
          return (
            <button key={t} className="card press" onClick={() => setType(t)}
              style={{ padding: 12, textAlign: 'left', border: on ? '2px solid #EBA63F' : '2px solid transparent' }}>
              <div className="square-chip" style={{ width: 34, height: 34, background: m.tint, color: m.text }}>{m.shortChip}</div>
              <div className="small" style={{ fontWeight: 600, marginTop: 8 }}>{m.label}</div>
              <div className="tiny muted">{m.timeRange}</div>
            </button>
          )
        })}
      </div>

      {isLeave ? (
        <div className="card" style={{ padding: 12, marginTop: 14 }}>
          <div className="small secondary" style={{ fontWeight: 600, marginBottom: 8 }}>ประเภทวันลา</div>
          <div className="row" style={{ flexWrap: 'wrap', gap: 8 }}>
            {LEAVES.map((l) => {
              const m = LEAVE_META[l]
              const on = leave === l
              const Icon = m.icon
              return (
                <button key={l} className="chip press" onClick={() => setLeave(l)}
                  style={{ background: on ? m.color : m.tint, color: on ? '#fff' : m.color }}>
                  <Icon size={14} /> {m.label}
                </button>
              )
            })}
          </div>
        </div>
      ) : type !== 'custom' && (
        <div className="card" style={{ padding: 14, marginTop: 14 }}>
          <div className="between">
            <span className="small" style={{ fontWeight: 600 }}>⏱️ ทำ OT</span>
            <input type="checkbox" checked={otOn} onChange={(e) => setOtOn(e.target.checked)} style={{ width: 22, height: 22 }} />
          </div>
          {otOn && (
            <div className="between" style={{ marginTop: 12 }}>
              <span className="small secondary">จำนวนชั่วโมง</span>
              <div className="row">
                <button className="square-chip press" style={{ width: 32, height: 32, background: 'var(--surface-peach)', color: 'var(--peach-active)' }} onClick={() => setOtHours(Math.max(1, otHours - 1))}>−</button>
                <span style={{ fontWeight: 700, width: 28, textAlign: 'center' }}>{otHours}</span>
                <button className="square-chip press" style={{ width: 32, height: 32, background: 'var(--surface-peach)', color: 'var(--peach-active)' }} onClick={() => setOtHours(otHours + 1)}>+</button>
              </div>
            </div>
          )}
        </div>
      )}

      <div className="card" style={{ padding: 16, marginTop: 14, background: SHIFT_META.morning.tint }}>
        <div className="tiny" style={{ color: SHIFT_META.morning.text }}>รายได้เวรนี้ (คำนวณอัตโนมัติ)</div>
        <div className="between" style={{ marginTop: 4 }}>
          <span className="tiny" style={{ color: SHIFT_META.morning.text }}>{isLeave ? 'วันลา ไม่มีรายได้' : SHIFT_META[type].label}</span>
          <span style={{ fontSize: 24, fontWeight: 700, color: SHIFT_META.morning.text }}>{baht(income)}</span>
        </div>
      </div>

      <button className="btn-grad press" style={{ marginTop: 16 }} onClick={save}>
        {editing ? 'บันทึกการแก้ไข' : isLeave ? 'เพิ่มวันหยุด' : 'เพิ่มเวร'}
      </button>

      {editing && (
        <button className="press" onClick={() => { deleteShift(editing.id); onClose() }}
          style={{ width: '100%', marginTop: 10, padding: 13, borderRadius: 14, color: 'var(--expense-rose)', background: 'rgba(206,80,121,0.1)', fontWeight: 600 }}>
          🗑️ ลบเวรนี้
        </button>
      )}
      {/* range leave for multi-day */}
      {isLeave && !editing && <MultiDayLeave date={date} leave={leave} onDone={(e) => { setLeaveRange(date, e, leave); onClose() }} />}
    </Sheet>
  )
}

function MultiDayLeave({ date, leave, onDone }: { date: string; leave: LeaveType; onDone: (end: string) => void }) {
  const [on, setOn] = useState(false)
  const [end, setEnd] = useState(date)
  return (
    <div className="card" style={{ padding: 14, marginTop: 10 }}>
      <div className="between">
        <span className="small" style={{ fontWeight: 600 }}>หยุดหลายวัน</span>
        <input type="checkbox" checked={on} onChange={(e) => setOn(e.target.checked)} style={{ width: 22, height: 22 }} />
      </div>
      {on && (
        <div style={{ marginTop: 12 }}>
          <div className="between">
            <span className="small secondary">ถึงวันที่</span>
            <input className="field" type="date" value={end} min={date} onChange={(e) => setEnd(e.target.value)} style={{ width: 'auto' }} />
          </div>
          <button className="btn-grad press" style={{ marginTop: 12, background: LEAVE_META[leave].color, boxShadow: 'none' }} onClick={() => onDone(end)}>
            บันทึกวันหยุดช่วงนี้
          </button>
        </div>
      )}
    </div>
  )
}
