import type { Shift, PayRates, LeaveType } from './types'

export function shiftIncome(shift: Shift, rates: PayRates): number {
  let base = 0
  switch (shift.type) {
    case 'morning': base = rates.morningShift; break
    case 'afternoon': base = rates.afternoonShift; break
    case 'night': base = rates.nightShift; break
    case 'ot': base = rates.morningShift; break
    case 'off':
    case 'custom': base = 0; break
  }
  return base + shift.otHours * rates.otPerHour
}

export function resolvedLeave(shift: Shift): LeaveType | undefined {
  if (shift.type !== 'off') return undefined
  return shift.leaveType ?? 'dayOff'
}

export function uid(): string {
  return crypto.randomUUID()
}
