import { useState } from 'react'
import { useStore } from '../store'
import { DEFAULT_RATES } from '../types'
import { MascotFull } from '../components/Mascot'

export default function Onboarding() {
  const complete = useStore((s) => s.completeOnboarding)
  const [step, setStep] = useState(0)
  const [name, setName] = useState('')
  const [role, setRole] = useState('พยาบาลวิชาชีพ')
  const [hospital, setHospital] = useState('')
  const [rates, setRates] = useState(DEFAULT_RATES)

  function finish() {
    complete({ name: name.trim() || 'คุณพยาบาล', role: role.trim(), hospital: hospital.trim() }, rates)
  }

  return (
    <div className="screen" style={{ paddingTop: 24 }}>
      {step === 0 ? (
        <div className="col" style={{ alignItems: 'center', textAlign: 'center', gap: 16, marginTop: 24 }}>
          <MascotFull size={200} />
          <h1 className="h1">ยินดีต้อนรับสู่ PICHY</h1>
          <p className="secondary" style={{ margin: 0 }}>
            จัดการตารางเวรและคำนวณรายได้ของคุณ
            <br />เริ่มต้นด้วยการตั้งค่าโปรไฟล์และอัตราค่าเวร
          </p>
          <button className="btn-grad press" style={{ marginTop: 16 }} onClick={() => setStep(1)}>
            เริ่มต้นใช้งาน
          </button>
        </div>
      ) : step === 1 ? (
        <div className="col" style={{ gap: 16 }}>
          <h1 className="h1">โปรไฟล์ของคุณ</h1>
          <Labeled label="ชื่อ">
            <input className="field" value={name} onChange={(e) => setName(e.target.value)} placeholder="เช่น พยาบาลแนน" />
          </Labeled>
          <Labeled label="ตำแหน่ง">
            <input className="field" value={role} onChange={(e) => setRole(e.target.value)} />
          </Labeled>
          <Labeled label="โรงพยาบาล">
            <input className="field" value={hospital} onChange={(e) => setHospital(e.target.value)} placeholder="เช่น รพ.ศิริราช" />
          </Labeled>
          <button className="btn-grad press" style={{ marginTop: 8 }} onClick={() => setStep(2)}>ถัดไป</button>
        </div>
      ) : (
        <div className="col" style={{ gap: 16 }}>
          <h1 className="h1">อัตราค่าเวร</h1>
          <p className="secondary tiny" style={{ margin: 0 }}>ค่าเวรของแต่ละโรงพยาบาลไม่เท่ากัน กรอกให้ตรงกับของคุณ</p>
          <div className="card" style={{ padding: 4 }}>
            <RateRow label="เวรเช้า" value={rates.morningShift} onChange={(v) => setRates({ ...rates, morningShift: v })} />
            <RateRow label="เวรบ่าย" value={rates.afternoonShift} onChange={(v) => setRates({ ...rates, afternoonShift: v })} />
            <RateRow label="เวรดึก" value={rates.nightShift} onChange={(v) => setRates({ ...rates, nightShift: v })} />
            <RateRow label="OT ต่อชั่วโมง" value={rates.otPerHour} onChange={(v) => setRates({ ...rates, otPerHour: v })} last />
          </div>
          <button className="btn-grad press" style={{ marginTop: 8 }} onClick={finish}>เริ่มใช้งาน</button>
        </div>
      )}
    </div>
  )
}

function Labeled({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="col" style={{ gap: 6 }}>
      <span className="small secondary" style={{ fontWeight: 600 }}>{label}</span>
      {children}
    </div>
  )
}

function RateRow({ label, value, onChange, last }: { label: string; value: number; onChange: (v: number) => void; last?: boolean }) {
  return (
    <div>
      <div className="between" style={{ padding: '14px 12px' }}>
        <span className="small" style={{ fontWeight: 600 }}>{label}</span>
        <div className="row" style={{ gap: 4, background: 'var(--surface-peach)', borderRadius: 10, padding: '6px 12px' }}>
          <span className="muted">฿</span>
          <input
            type="number" inputMode="numeric" value={value || ''}
            onChange={(e) => onChange(Number(e.target.value) || 0)}
            style={{ width: 84, textAlign: 'right', border: 'none', background: 'transparent', fontWeight: 700, fontSize: 16 }}
          />
        </div>
      </div>
      {!last && <div className="divider" style={{ marginLeft: 60 }} />}
    </div>
  )
}
