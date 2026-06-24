import type { Shift, Transaction, PayRates, ShiftType, LeaveType, Activity } from './types'
import { shiftIncome, resolvedLeave } from './domain'
import { SHIFT_META } from './meta'
import { sameMonth } from './utils/thaiDate'
import { sameFiscalYear } from './utils/fiscalYear'

/** Income transactions derived from shifts (not stored). */
export function shiftTransactions(shifts: Shift[], rates: PayRates): Transaction[] {
  return shifts.flatMap((shift) => {
    const amount = shiftIncome(shift, rates)
    if (amount <= 0) return []
    const ot = shift.otHours > 0 ? ` + OT ${shift.otHours}ชม.` : ''
    return [{
      id: `shift-${shift.id}`,
      date: shift.date,
      amount,
      title: `เวร${SHIFT_META[shift.type].label}${ot}`,
      category: SHIFT_META[shift.type].label,
      kind: 'income' as const,
      source: 'shift' as const,
      shiftType: shift.type,
    }]
  })
}

export function allTransactions(shifts: Shift[], manual: Transaction[], rates: PayRates): Transaction[] {
  return [...manual, ...shiftTransactions(shifts, rates)].sort((a, b) => (a.date > b.date ? -1 : 1))
}

export function shiftsOn(shifts: Shift[], dayKey: string): Shift[] {
  return shifts
    .filter((s) => s.date === dayKey)
    .sort((a, b) => startKey(a) - startKey(b))
}

function startKey(s: Shift): number {
  const st = SHIFT_META[s.type].start
  return st ? st.hour * 60 + st.minute : 9999
}

export function activitiesOn(activities: Activity[], dayKey: string): Activity[] {
  return activities.filter((a) => a.date === dayKey).sort((a, b) => (a.time < b.time ? -1 : 1))
}

export function monthTransactions(shifts: Shift[], manual: Transaction[], rates: PayRates, monthKey: string): Transaction[] {
  return allTransactions(shifts, manual, rates).filter((t) => sameMonth(t.date, monthKey))
}

export function monthlyIncome(shifts: Shift[], manual: Transaction[], rates: PayRates, monthKey: string): number {
  return monthTransactions(shifts, manual, rates, monthKey)
    .filter((t) => t.kind === 'income')
    .reduce((sum, t) => sum + t.amount, 0)
}

export function monthlyExpense(shifts: Shift[], manual: Transaction[], rates: PayRates, monthKey: string): number {
  return monthTransactions(shifts, manual, rates, monthKey)
    .filter((t) => t.kind === 'expense')
    .reduce((sum, t) => sum + Math.abs(t.amount), 0)
}

export function shiftsInMonth(shifts: Shift[], monthKey: string): Shift[] {
  return shifts.filter((s) => sameMonth(s.date, monthKey))
}

/** Base shift pay only (OT excluded — reported separately). */
export function incomeFromShifts(shifts: Shift[], rates: PayRates, monthKey: string): number {
  return shiftsInMonth(shifts, monthKey)
    .filter((s) => s.type !== 'ot')
    .reduce((sum, s) => sum + Math.max(0, shiftIncome(s, rates) - s.otHours * rates.otPerHour), 0)
}

export function incomeFromOT(shifts: Shift[], rates: PayRates, monthKey: string): number {
  const month = shiftsInMonth(shifts, monthKey)
  const otHours = month.reduce((sum, s) => sum + s.otHours * rates.otPerHour, 0)
  const otShifts = month.filter((s) => s.type === 'ot').length * rates.morningShift
  return otHours + otShifts
}

export function shiftCountsInMonth(shifts: Shift[], monthKey: string): Record<ShiftType, number> {
  const counts = { morning: 0, afternoon: 0, night: 0, off: 0, ot: 0, custom: 0 } as Record<ShiftType, number>
  for (const s of shiftsInMonth(shifts, monthKey)) {
    if (s.type !== 'off') counts[s.type] += 1
  }
  const otExtra = shiftsInMonth(shifts, monthKey).filter((s) => s.otHours > 0 && s.type !== 'ot').length
  counts.ot += otExtra
  return counts
}

export function leaveUsed(shifts: Shift[], type: LeaveType, anchor: string): number {
  return shifts.filter((s) => s.type === 'off' && resolvedLeave(s) === type && sameFiscalYear(s.date, anchor)).length
}

export function leaveDaysInMonth(shifts: Shift[], monthKey: string): Shift[] {
  return shiftsInMonth(shifts, monthKey).filter((s) => s.type === 'off').sort((a, b) => (a.date < b.date ? -1 : 1))
}

export function monthlyIncomeSeries(
  shifts: Shift[], manual: Transaction[], rates: PayRates, anchorMonth: Date, length = 6,
): { label: string; value: number }[] {
  const out: { label: string; value: number }[] = []
  for (let i = length - 1; i >= 0; i--) {
    const d = new Date(anchorMonth.getFullYear(), anchorMonth.getMonth() - i, 1)
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-01`
    out.push({ label: String(d.getMonth() + 1), value: monthlyIncome(shifts, manual, rates, key) })
  }
  return out
}
