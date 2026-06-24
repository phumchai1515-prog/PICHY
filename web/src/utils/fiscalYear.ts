// Thai government fiscal year: 1 Oct – 30 Sep.
import { fromKey } from './thaiDate'

const START_MONTH = 9 // October (0-based)

export function fiscalRange(key: string): { start: string; end: string } {
  const d = fromKey(key)
  const year = d.getFullYear()
  const startYear = d.getMonth() >= START_MONTH ? year : year - 1
  const start = new Date(startYear, START_MONTH, 1)
  const end = new Date(startYear + 1, START_MONTH, 0) // 30 Sep next year
  return { start: keyOf(start), end: keyOf(end) }
}

export function sameFiscalYear(key: string, anchor: string): boolean {
  const r = fiscalRange(anchor)
  return key >= r.start && key <= r.end
}

export function fiscalBuddhistYear(key: string): number {
  const d = fromKey(key)
  const endGreg = d.getMonth() >= START_MONTH ? d.getFullYear() + 1 : d.getFullYear()
  return endGreg + 543
}

export function fiscalLabel(key: string): string {
  return `ปีงบประมาณ ${fiscalBuddhistYear(key)}`
}

function keyOf(date: Date): string {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}
