import { useStore } from '../store'
import {
  monthlyIncomeSeries, shiftCountsInMonth, incomeFromShifts, incomeFromOT, leaveUsed, leaveDaysInMonth,
} from '../selectors'
import { SHIFT_META, LEAVE_META, QUOTA_KINDS } from '../meta'
import { resolvedLeave } from '../domain'
import { baht } from '../utils/money'
import { todayKey, toKey, monthYearLong } from '../utils/thaiDate'
import { fiscalLabel } from '../utils/fiscalYear'

export default function SummaryScreen() {
  const { shifts, transactions, rates, quota } = useStore()
  const anchorMonth = new Date()
  const monthKey = toKey(new Date(anchorMonth.getFullYear(), anchorMonth.getMonth(), 1))
  const today = todayKey()

  const series = monthlyIncomeSeries(shifts, transactions, rates, anchorMonth)
  const maxVal = Math.max(...series.map((s) => s.value), 1)
  const counts = shiftCountsInMonth(shifts, monthKey)
  const order = ['morning', 'afternoon', 'night', 'ot'] as const
  const total = order.reduce((s, t) => s + counts[t], 0)
  const baseIncome = incomeFromShifts(shifts, rates, monthKey)
  const otIncome = incomeFromOT(shifts, rates, monthKey)
  const monthLeaves = leaveDaysInMonth(shifts, monthKey)

  // donut via conic-gradient
  let acc = 0
  const stops = order.filter((t) => counts[t] > 0).map((t) => {
    const start = (acc / Math.max(total, 1)) * 360
    acc += counts[t]
    const end = (acc / Math.max(total, 1)) * 360
    return `${SHIFT_META[t].dot} ${start}deg ${end}deg`
  })
  const conic = stops.length ? `conic-gradient(${stops.join(',')})` : 'conic-gradient(#EFE7E0 0deg 360deg)'

  return (
    <div className="screen">
      <div className="col" style={{ marginBottom: 16 }}>
        <span className="h1">สรุปเดือนนี้</span>
        <span className="tiny muted">{monthYearLong(anchorMonth)}</span>
      </div>

      <div className="card" style={{ padding: 16, marginBottom: 16 }}>
        <div className="small secondary" style={{ fontWeight: 600, marginBottom: 12 }}>รายได้ย้อนหลัง 6 เดือน</div>
        <div className="row" style={{ alignItems: 'flex-end', height: 110, gap: 8 }}>
          {series.map((s, i) => (
            <div key={i} className="col grow" style={{ alignItems: 'center', gap: 4 }}>
              <div style={{ width: '70%', height: `${(s.value / maxVal) * 88}px`, minHeight: 3, borderRadius: 6, background: i === series.length - 1 ? 'linear-gradient(var(--peach-grad-a),var(--peach-grad-b))' : 'var(--surface-peach)' }} />
              <span className="tiny muted">{s.label}</span>
            </div>
          ))}
        </div>
      </div>

      <div className="card" style={{ padding: 16, marginBottom: 16 }}>
        <div className="small secondary" style={{ fontWeight: 600, marginBottom: 12 }}>สัดส่วนเวรเดือนนี้</div>
        <div className="row" style={{ gap: 20 }}>
          <div style={{ width: 100, height: 100, borderRadius: '50%', background: conic, position: 'relative', flexShrink: 0 }}>
            <div style={{ position: 'absolute', inset: 16, borderRadius: '50%', background: '#fff', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
              <span className="tiny muted">เวรรวม</span>
              <span style={{ fontSize: 20, fontWeight: 700 }}>{total}</span>
            </div>
          </div>
          <div className="grow col" style={{ gap: 8 }}>
            {order.map((t) => (
              <div key={t} className="row" style={{ gap: 8 }}>
                <i style={{ width: 12, height: 12, borderRadius: 4, background: SHIFT_META[t].dot }} />
                <span className="small">{SHIFT_META[t].label} {counts[t]}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="row" style={{ gap: 12, marginBottom: 16 }}>
        <Tile title="รายได้จากเวร" amount={baseIncome} bg={SHIFT_META.morning.tint} fg={SHIFT_META.morning.text} />
        <Tile title="รายได้ OT" amount={otIncome} bg={SHIFT_META.ot.tint} fg={SHIFT_META.ot.text} />
      </div>

      <div className="card" style={{ padding: 16 }}>
        <div className="between" style={{ marginBottom: 12 }}>
          <span className="h2">วันหยุด / วันลา</span>
          <span className="tiny chip" style={{ background: 'var(--surface-peach)', color: 'var(--text-muted)' }}>{fiscalLabel(today)}</span>
        </div>
        <div className="small secondary" style={{ fontWeight: 600, marginBottom: 8 }}>เดือนนี้หยุด/ลา {monthLeaves.length} วัน</div>
        <div className="row" style={{ flexWrap: 'wrap', gap: 6, marginBottom: 14 }}>
          {monthLeaves.map((s) => {
            const k = resolvedLeave(s)!
            return <span key={s.id} className="chip" style={{ background: LEAVE_META[k].tint, color: LEAVE_META[k].color }}>{Number(s.date.slice(8))} {LEAVE_META[k].shortLabel}</span>
          })}
        </div>
        <div className="col" style={{ gap: 12 }}>
          {QUOTA_KINDS.map((k) => {
            const totalQ = quota[k as 'sick' | 'personal' | 'vacation']
            const used = leaveUsed(shifts, k, today)
            const frac = totalQ > 0 ? Math.min(1, used / totalQ) : 0
            return (
              <div key={k} className="col" style={{ gap: 5 }}>
                <div className="between">
                  <span className="small" style={{ fontWeight: 600 }}><i style={{ width: 8, height: 8, borderRadius: 8, background: LEAVE_META[k].color, display: 'inline-block', marginRight: 6 }} />{LEAVE_META[k].label}</span>
                  <span className="tiny" style={{ fontWeight: 600, color: used >= totalQ ? 'var(--expense-rose)' : 'var(--text-secondary)' }}>ใช้ {used}/{totalQ} · เหลือ {Math.max(0, totalQ - used)}</span>
                </div>
                <div style={{ height: 6, borderRadius: 6, background: LEAVE_META[k].tint }}>
                  <div style={{ width: `${frac * 100}%`, height: 6, borderRadius: 6, background: LEAVE_META[k].color }} />
                </div>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}

function Tile({ title, amount, bg, fg }: { title: string; amount: number; bg: string; fg: string }) {
  return (
    <div className="grow col" style={{ background: bg, borderRadius: 16, padding: 16, gap: 8 }}>
      <span className="tiny" style={{ color: fg, opacity: 0.85 }}>{title}</span>
      <span style={{ fontSize: 20, fontWeight: 700, color: fg }}>{baht(amount)}</span>
    </div>
  )
}
