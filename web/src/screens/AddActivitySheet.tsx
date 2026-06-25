import { useState } from 'react'
import Sheet from '../components/Sheet'
import { useStore } from '../store'
import { ACTIVITY_META } from '../meta'
import type { ActivityCategory } from '../types'
import { uid } from '../domain'

const CATS: ActivityCategory[] = ['morningShift', 'meeting', 'ot', 'personal']

export default function AddActivitySheet({ date, onClose }: { date: string; onClose: () => void }) {
  const addActivity = useStore((s) => s.addActivity)
  const [time, setTime] = useState('08:00')
  const [title, setTitle] = useState('')
  const [cat, setCat] = useState<ActivityCategory>('personal')
  const [note, setNote] = useState('')

  function save() {
    if (!title.trim()) return
    addActivity({ id: uid(), date, time, title: title.trim(), category: cat, note: note.trim() || undefined })
    onClose()
  }

  return (
    <Sheet onClose={onClose}>
      <h2 className="h2" style={{ marginBottom: 12 }}>เพิ่มกิจกรรม</h2>
      <div className="col" style={{ gap: 14 }}>
        <div className="card between" style={{ padding: 14 }}>
          <span className="small" style={{ fontWeight: 600 }}>เวลา</span>
          <input className="field" type="time" value={time} onChange={(e) => setTime(e.target.value)} style={{ width: 'auto' }} />
        </div>
        <input className="field" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="ชื่อกิจกรรม เช่น ประชุมทีม" />
        <div className="row" style={{ flexWrap: 'wrap', gap: 8 }}>
          {CATS.map((c) => {
            const m = ACTIVITY_META[c]
            const on = cat === c
            const Icon = m.icon
            return (
              <button key={c} className="chip press" onClick={() => setCat(c)}
                style={{ background: on ? m.color : '#fff', color: on ? '#fff' : 'var(--text-secondary)', border: on ? 'none' : '1px solid var(--divider)' }}>
                <Icon size={14} /> {m.label}
              </button>
            )
          })}
        </div>
        <input className="field" value={note} onChange={(e) => setNote(e.target.value)} placeholder="บันทึก (ไม่บังคับ)" />
        <button className="btn-grad press" disabled={!title.trim()} onClick={save}>เพิ่มกิจกรรม</button>
      </div>
    </Sheet>
  )
}
