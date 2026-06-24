import { useState } from 'react'
import Sheet from '../components/Sheet'
import { useStore } from '../store'
import { EXPENSE_META } from '../meta'
import type { ExpenseCategory, TransactionKind } from '../types'
import { uid } from '../domain'
import { todayKey } from '../utils/thaiDate'

const CATS: ExpenseCategory[] = ['food', 'transport', 'shopping', 'bills', 'other']

export default function AddTransactionSheet({ onClose }: { onClose: () => void }) {
  const addTransaction = useStore((s) => s.addTransaction)
  const [kind, setKind] = useState<TransactionKind>('expense')
  const [amount, setAmount] = useState(0)
  const [title, setTitle] = useState('')
  const [cat, setCat] = useState<ExpenseCategory>('food')
  const [date, setDate] = useState(todayKey())
  const [note, setNote] = useState('')

  const canSave = amount > 0 && title.trim().length > 0

  function save() {
    if (!canSave) return
    addTransaction({
      id: uid(),
      date,
      amount: kind === 'expense' ? -Math.abs(amount) : Math.abs(amount),
      title: title.trim(),
      category: kind === 'expense' ? EXPENSE_META[cat].label : 'รายรับ',
      kind,
      source: 'manual',
      note: note.trim() || undefined,
    })
    onClose()
  }

  return (
    <Sheet onClose={onClose}>
      <h2 className="h2" style={{ marginBottom: 12 }}>เพิ่มรายการ</h2>
      <div className="col" style={{ gap: 14 }}>
        <div className="seg">
          <button className={kind === 'expense' ? 'on' : ''} style={kind === 'expense' ? { background: 'var(--expense-rose)' } : {}} onClick={() => setKind('expense')}>รายจ่าย</button>
          <button className={kind === 'income' ? 'on' : ''} style={kind === 'income' ? { background: 'var(--income-green)' } : {}} onClick={() => setKind('income')}>รายรับ</button>
        </div>

        <div className="card between" style={{ padding: 16 }}>
          <span className="small" style={{ fontWeight: 600 }}>จำนวนเงิน</span>
          <div className="row" style={{ gap: 4, background: 'var(--surface-peach)', borderRadius: 10, padding: '6px 12px' }}>
            <span className="muted">฿</span>
            <input type="number" inputMode="numeric" value={amount || ''} onChange={(e) => setAmount(Number(e.target.value) || 0)}
              style={{ width: 110, textAlign: 'right', border: 'none', background: 'transparent', fontWeight: 700, fontSize: 18 }} />
          </div>
        </div>

        <input className="field" value={title} onChange={(e) => setTitle(e.target.value)}
          placeholder={kind === 'expense' ? 'เช่น ค่าข้าว, ค่าเดินทาง' : 'เช่น โบนัส, รายได้พิเศษ'} />

        {kind === 'expense' && (
          <div className="row" style={{ flexWrap: 'wrap', gap: 8 }}>
            {CATS.map((c) => {
              const on = cat === c
              return (
                <button key={c} className="chip press" onClick={() => setCat(c)}
                  style={{ background: on ? 'var(--peach-primary)' : '#fff', color: on ? '#fff' : 'var(--text-secondary)', border: on ? 'none' : '1px solid var(--divider)' }}>
                  {EXPENSE_META[c].icon} {EXPENSE_META[c].label}
                </button>
              )
            })}
          </div>
        )}

        <div className="card between" style={{ padding: 14 }}>
          <span className="small" style={{ fontWeight: 600 }}>วันที่</span>
          <input className="field" type="date" value={date} onChange={(e) => setDate(e.target.value)} style={{ width: 'auto' }} />
        </div>

        <input className="field" value={note} onChange={(e) => setNote(e.target.value)} placeholder="บันทึก (ไม่บังคับ)" />
        <button className="btn-grad press" disabled={!canSave} onClick={save}>{kind === 'expense' ? 'เพิ่มรายจ่าย' : 'เพิ่มรายรับ'}</button>
      </div>
    </Sheet>
  )
}
