import { useState } from 'react'
import { useStore } from '../store'
import { monthTransactions, monthlyIncome, monthlyExpense } from '../selectors'
import { SHIFT_META, EXPENSE_META } from '../meta'
import { baht, signed } from '../utils/money'
import { todayKey, dayMonthShort, fromKey } from '../utils/thaiDate'
import type { Transaction } from '../types'
import { Wallet, type LucideIcon } from 'lucide-react'
import AddTransactionSheet from './AddTransactionSheet'

export default function WalletScreen() {
  const { shifts, transactions, rates } = useStore()
  const [adding, setAdding] = useState(false)
  const month = todayKey()
  const income = monthlyIncome(shifts, transactions, rates, month)
  const expense = monthlyExpense(shifts, transactions, rates, month)
  const txs = monthTransactions(shifts, transactions, rates, month)

  const groups = groupByDay(txs)

  return (
    <div className="screen">
      <div className="hero" style={{ marginBottom: 16 }}>
        <div className="tiny" style={{ opacity: 0.85 }}>ยอดคงเหลือเดือนนี้</div>
        <div style={{ fontSize: 32, fontWeight: 700, marginTop: 2 }}>{baht(income - expense)}</div>
        <div className="row" style={{ gap: 20, marginTop: 14 }}>
          <div className="col"><span className="tiny" style={{ opacity: 0.8 }}>รายรับ</span><span style={{ fontWeight: 600 }}>{baht(income)}</span></div>
          <div className="col"><span className="tiny" style={{ opacity: 0.8 }}>รายจ่าย</span><span style={{ fontWeight: 600 }}>{baht(expense)}</span></div>
        </div>
      </div>

      <div className="between" style={{ marginBottom: 8 }}>
        <span className="h2">รายการเดือนนี้</span>
        <span className="tiny muted">{txs.length} รายการ</span>
      </div>

      {groups.length === 0 ? (
        <div className="col" style={{ alignItems: 'center', gap: 8, padding: 32, color: 'var(--text-muted)' }}>
          <span style={{ fontSize: 28 }}>🗒️</span>
          <span className="small" style={{ fontWeight: 600 }}>ยังไม่มีรายการในเดือนนี้</span>
          <span className="tiny">แตะปุ่ม ＋ เพื่อเพิ่มรายรับ/รายจ่าย</span>
        </div>
      ) : groups.map((g) => (
        <div key={g.day} style={{ marginBottom: 14 }}>
          <div className="tiny secondary" style={{ fontWeight: 600, marginBottom: 6, paddingLeft: 4 }}>{g.label}</div>
          <div className="card" style={{ overflow: 'hidden' }}>
            {g.items.map((t, i) => (
              <div key={t.id}>
                <Row t={t} />
                {i < g.items.length - 1 && <div className="divider" style={{ marginLeft: 60 }} />}
              </div>
            ))}
          </div>
        </div>
      ))}

      <button className="fab press" onClick={() => setAdding(true)}>＋</button>
      {adding && <AddTransactionSheet onClose={() => setAdding(false)} />}
    </div>
  )
}

function Row({ t }: { t: Transaction }) {
  const bg = t.shiftType ? SHIFT_META[t.shiftType].tint : 'var(--surface-peach)'
  const fg = t.shiftType ? SHIFT_META[t.shiftType].text : 'var(--peach-primary)'
  const ExpenseIcon = iconFor(t.category)
  return (
    <div className="row" style={{ padding: 14 }}>
      <div className="square-chip" style={{ background: bg, color: fg }}>
        {t.shiftType ? SHIFT_META[t.shiftType].shortChip : <ExpenseIcon size={18} />}
      </div>
      <div className="grow col" style={{ gap: 2 }}>
        <span className="small" style={{ fontWeight: 600 }}>{t.title}</span>
        <span className="tiny muted">{t.category}</span>
      </div>
      <span style={{ fontWeight: 700, color: t.kind === 'income' ? 'var(--income-green)' : 'var(--expense-rose)' }}>{signed(t.amount)}</span>
    </div>
  )
}

function iconFor(label: string): LucideIcon {
  for (const m of Object.values(EXPENSE_META)) if (m.label === label) return m.icon
  return Wallet
}

function groupByDay(txs: Transaction[]): { day: string; label: string; items: Transaction[] }[] {
  const map = new Map<string, Transaction[]>()
  for (const t of txs) {
    const arr = map.get(t.date) ?? []
    arr.push(t)
    map.set(t.date, arr)
  }
  const today = todayKey()
  const yKey = (() => { const d = fromKey(today); d.setDate(d.getDate() - 1); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}` })()
  return [...map.keys()].sort((a, b) => (a > b ? -1 : 1)).map((day) => ({
    day,
    label: day === today ? `วันนี้ · ${dayMonthShort(day)}` : day === yKey ? `เมื่อวาน · ${dayMonthShort(day)}` : dayMonthShort(day),
    items: map.get(day)!,
  }))
}
