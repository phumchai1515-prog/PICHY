import { useRef, useState } from 'react'
import {
  Sunrise, Sunset, Moon, Clock, Bell, FileText, Trash2, ChevronRight, Camera,
  type LucideIcon,
} from 'lucide-react'
import { useStore } from '../store'
import { SHIFT_META, REMINDER_LABELS } from '../meta'
import { shiftIncome } from '../domain'
import { baht } from '../utils/money'
import { todayKey, dateLabelMedium, fromKey } from '../utils/thaiDate'
import { exportSchedule } from '../lib/exportSchedule'
import { fileToAvatar } from '../lib/image'
import type { ReminderLead } from '../types'
import Sheet from '../components/Sheet'
import Avatar from '../components/Avatar'

const LEADS: ReminderLead[] = [30, 60, 120, 180, 300, 480, 720]

export default function ProfileScreen() {
  const { profile, rates, settings, shifts, updateSettings, updateRates, updateProfile, resetAll } = useStore()
  const [editRates, setEditRates] = useState(false)
  const [editProfile, setEditProfile] = useState(false)

  // In-app reminders: upcoming shifts in the next 7 days.
  const today = todayKey()
  const upcoming = shifts
    .filter((s) => s.date >= today && s.type !== 'off' && s.type !== 'custom')
    .sort((a, b) => (a.date < b.date ? -1 : 1))
    .slice(0, 5)

  return (
    <div className="screen">
      <button className="card press" onClick={() => setEditProfile(true)} style={{ width: '100%', padding: 20, marginBottom: 20, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
        <Avatar profile={profile} size={72} />
        <span style={{ fontSize: 18, fontWeight: 600 }}>{profile.name || 'คุณพยาบาล'}</span>
        <span className="tiny muted">{[profile.role, profile.hospital].filter(Boolean).join(' · ') || 'แตะเพื่อแก้ไข'}</span>
      </button>

      <Section title="อัตราค่าเวร (ใช้คำนวณรายได้)">
        <button className="press" onClick={() => setEditRates(true)} style={{ width: '100%' }}>
          <Row icon={Sunrise} label="เวรเช้า" value={baht(rates.morningShift)} chevron />
        </button>
        <Divider />
        <Row icon={Sunset} label="เวรบ่าย" value={baht(rates.afternoonShift)} />
        <Divider />
        <Row icon={Moon} label="เวรดึก" value={baht(rates.nightShift)} />
        <Divider />
        <Row icon={Clock} label="OT ต่อชั่วโมง" value={baht(rates.otPerHour)} />
      </Section>

      <Section title="แจ้งเตือนในแอป">
        <RowToggle icon={Bell} label="เตือนเวรที่ใกล้ถึง" on={settings.shiftReminder} onChange={(v) => updateSettings({ ...settings, shiftReminder: v })} />
        {settings.shiftReminder && (
          <>
            <Divider />
            <div style={{ padding: '10px 14px' }}>
              <div className="tiny muted" style={{ marginBottom: 6 }}>เตือนล่วงหน้า</div>
              <div className="row" style={{ flexWrap: 'wrap', gap: 6 }}>
                {LEADS.map((l) => (
                  <button key={l} className="chip press" onClick={() => updateSettings({ ...settings, reminderLead: l })}
                    style={{ background: settings.reminderLead === l ? 'var(--peach-primary)' : '#fff', color: settings.reminderLead === l ? '#fff' : 'var(--text-secondary)', border: '1px solid var(--divider)' }}>
                    {REMINDER_LABELS[l]}
                  </button>
                ))}
              </div>
            </div>
          </>
        )}
      </Section>

      {settings.shiftReminder && (
        <Section title="เวรที่ใกล้ถึง">
          {upcoming.length === 0 ? (
            <div className="muted small" style={{ padding: 14 }}>ไม่มีเวรที่กำลังจะถึง</div>
          ) : upcoming.map((s, i) => (
            <div key={s.id}>
              <div className="row" style={{ padding: '12px 14px' }}>
                <div className="square-chip" style={{ background: SHIFT_META[s.type].tint, color: SHIFT_META[s.type].text }}>{SHIFT_META[s.type].shortChip}</div>
                <div className="grow col" style={{ gap: 2 }}>
                  <span className="small" style={{ fontWeight: 600 }}>เวร{SHIFT_META[s.type].label} {leadHint(s.date)}</span>
                  <span className="tiny muted">{dateLabelMedium(s.date)} · {SHIFT_META[s.type].timeRange}</span>
                </div>
                <span className="small" style={{ fontWeight: 700, color: 'var(--income-green)' }}>{baht(shiftIncome(s, rates))}</span>
              </div>
              {i < upcoming.length - 1 && <Divider />}
            </div>
          ))}
        </Section>
      )}

      <Section title="ข้อมูล">
        <button className="press" style={{ width: '100%' }} onClick={() => exportSchedule(new Date(), shifts, rates, profile)}>
          <Row icon={FileText} label="ส่งออกตารางเวร PDF" value="" chevron />
        </button>
        <Divider />
        <button className="press" style={{ width: '100%' }} onClick={() => { if (confirm('ลบข้อมูลทั้งหมดและเริ่มใหม่?')) resetAll() }}>
          <Row icon={Trash2} label="ล้างข้อมูลทั้งหมด" value="" danger />
        </button>
      </Section>

      <p className="tiny muted" style={{ textAlign: 'center', marginTop: 16 }}>PICHY · เก็บข้อมูลในเครื่องของคุณเท่านั้น</p>

      {editRates && <RatesSheet onClose={() => setEditRates(false)} />}
      {editProfile && <ProfileSheet onClose={() => setEditProfile(false)} />}
    </div>
  )

  function ProfileSheet({ onClose }: { onClose: () => void }) {
    const [name, setName] = useState(profile.name)
    const [role, setRole] = useState(profile.role)
    const [hospital, setHospital] = useState(profile.hospital)
    const [avatar, setAvatar] = useState(profile.avatar)
    const fileRef = useRef<HTMLInputElement>(null)

    async function pick(e: React.ChangeEvent<HTMLInputElement>) {
      const file = e.target.files?.[0]
      if (!file) return
      try { setAvatar(await fileToAvatar(file)) } catch { /* ignore bad image */ }
    }

    return (
      <Sheet onClose={onClose}>
        <h2 className="h2" style={{ marginBottom: 12 }}>แก้ไขโปรไฟล์</h2>
        <div className="col" style={{ gap: 14, alignItems: 'center' }}>
          <button className="press" onClick={() => fileRef.current?.click()} style={{ position: 'relative' }}>
            <Avatar profile={{ ...profile, name, avatar }} size={84} />
            <span style={{ position: 'absolute', right: -2, bottom: -2, width: 28, height: 28, borderRadius: '50%', background: 'var(--peach-active)', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', border: '2px solid #fff' }}>
              <Camera size={15} />
            </span>
          </button>
          <input ref={fileRef} type="file" accept="image/*" hidden onChange={pick} />
          <div className="col" style={{ gap: 12, width: '100%' }}>
            <input className="field" value={name} onChange={(e) => setName(e.target.value)} placeholder="ชื่อ" />
            <input className="field" value={role} onChange={(e) => setRole(e.target.value)} placeholder="ตำแหน่ง" />
            <input className="field" value={hospital} onChange={(e) => setHospital(e.target.value)} placeholder="โรงพยาบาล" />
            <button className="btn-grad press" onClick={() => { updateProfile({ name, role, hospital, avatar }); onClose() }}>บันทึก</button>
          </div>
        </div>
      </Sheet>
    )
  }

  function RatesSheet({ onClose }: { onClose: () => void }) {
    const [r, setR] = useState(rates)
    const field = (label: string, key: keyof typeof r) => (
      <div className="between" style={{ padding: '12px 4px' }}>
        <span className="small" style={{ fontWeight: 600 }}>{label}</span>
        <div className="row" style={{ gap: 4, background: 'var(--surface-peach)', borderRadius: 10, padding: '6px 12px' }}>
          <span className="muted">฿</span>
          <input type="number" inputMode="numeric" value={r[key] || ''} onChange={(e) => setR({ ...r, [key]: Number(e.target.value) || 0 })}
            style={{ width: 90, textAlign: 'right', border: 'none', background: 'transparent', fontWeight: 700, fontSize: 16 }} />
        </div>
      </div>
    )
    return (
      <Sheet onClose={onClose}>
        <h2 className="h2" style={{ marginBottom: 12 }}>อัตราค่าเวร</h2>
        <div className="card" style={{ padding: '4px 14px' }}>
          {field('เวรเช้า', 'morningShift')}
          {field('เวรบ่าย', 'afternoonShift')}
          {field('เวรดึก', 'nightShift')}
          {field('OT ต่อชั่วโมง', 'otPerHour')}
        </div>
        <button className="btn-grad press" style={{ marginTop: 16 }} onClick={() => { updateRates(r); onClose() }}>บันทึก</button>
      </Sheet>
    )
  }
}

function leadHint(date: string): string {
  const start = fromKey(date)
  const diffDays = Math.round((start.getTime() - fromKey(todayKey()).getTime()) / 86400000)
  if (diffDays === 0) return '(วันนี้)'
  if (diffDays === 1) return '(พรุ่งนี้)'
  return `(อีก ${diffDays} วัน)`
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div style={{ marginBottom: 20 }}>
      <div className="small secondary" style={{ fontWeight: 600, padding: '0 4px 8px' }}>{title}</div>
      <div className="card" style={{ overflow: 'hidden' }}>{children}</div>
    </div>
  )
}
function Row({ icon: Icon, label, value, chevron, danger }: { icon: LucideIcon; label: string; value: string; chevron?: boolean; danger?: boolean }) {
  const color = danger ? 'var(--expense-rose)' : 'var(--text-secondary)'
  return (
    <div className="row" style={{ padding: '12px 14px' }}>
      <Icon size={19} color={color} />
      <span className="grow small" style={{ fontWeight: 600, color: danger ? 'var(--expense-rose)' : undefined, textAlign: 'left' }}>{label}</span>
      {value && <span className="small secondary">{value}</span>}
      {chevron && <ChevronRight size={18} color="var(--text-muted)" />}
    </div>
  )
}
function RowToggle({ icon: Icon, label, on, onChange }: { icon: LucideIcon; label: string; on: boolean; onChange: (v: boolean) => void }) {
  return (
    <div className="row" style={{ padding: '12px 14px' }}>
      <Icon size={19} color="var(--text-secondary)" />
      <span className="grow small" style={{ fontWeight: 600 }}>{label}</span>
      <input type="checkbox" checked={on} onChange={(e) => onChange(e.target.checked)} style={{ width: 24, height: 24 }} />
    </div>
  )
}
function Divider() { return <div className="divider" style={{ marginLeft: 46 }} /> }
