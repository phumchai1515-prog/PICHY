// Thai Buddhist-era date helpers. Works on 'YYYY-MM-DD' day strings.

const MONTHS_FULL = [
  'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
  'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
]
const MONTHS_SHORT = [
  'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
  'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
]
const WEEKDAYS_SHORT = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส']
const WEEKDAYS_FULL = ['อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์']

export const WEEKDAY_HEADERS = WEEKDAYS_SHORT

/** A Date at local midnight from a YYYY-MM-DD string. */
export function fromKey(key: string): Date {
  const [y, m, d] = key.split('-').map(Number)
  return new Date(y, m - 1, d)
}

/** YYYY-MM-DD string from a Date (local). */
export function toKey(date: Date): string {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

export function todayKey(): string {
  return toKey(new Date())
}

export function addMonths(date: Date, delta: number): Date {
  return new Date(date.getFullYear(), date.getMonth() + delta, 1)
}

export function sameMonth(a: string, b: string): boolean {
  return a.slice(0, 7) === b.slice(0, 7)
}

export function monthYearLong(date: Date): string {
  return `${MONTHS_FULL[date.getMonth()]} ${date.getFullYear() + 543}`
}

export function dayMonthShort(key: string): string {
  const d = fromKey(key)
  return `${d.getDate()} ${MONTHS_SHORT[d.getMonth()]}`
}

export function fullDate(key: string): string {
  const d = fromKey(key)
  return `${WEEKDAYS_FULL[d.getDay()]} ${d.getDate()} ${MONTHS_FULL[d.getMonth()]} ${d.getFullYear() + 543}`
}

export function dateLabelMedium(key: string): string {
  const d = fromKey(key)
  return `${WEEKDAYS_FULL[d.getDay()]} ${d.getDate()} ${MONTHS_SHORT[d.getMonth()]}`
}

/** 6×7 grid of day keys (or null) aligned Sunday-first for the given month. */
export function monthCells(month: Date): (string | null)[] {
  const year = month.getFullYear()
  const m = month.getMonth()
  const first = new Date(year, m, 1)
  const leading = first.getDay() // 0 = Sunday
  const daysInMonth = new Date(year, m + 1, 0).getDate()
  const cells: (string | null)[] = []
  for (let i = 0; i < leading; i++) cells.push(null)
  for (let day = 1; day <= daysInMonth; day++) cells.push(toKey(new Date(year, m, day)))
  while (cells.length % 7 !== 0) cells.push(null)
  return cells
}

export function greeting(): string {
  const h = new Date().getHours()
  if (h >= 5 && h < 12) return 'สวัสดีตอนเช้า ☀️'
  if (h >= 12 && h < 17) return 'สวัสดีตอนบ่าย'
  if (h >= 17 && h < 21) return 'สวัสดีตอนเย็น'
  return 'สวัสดีตอนค่ำ'
}
