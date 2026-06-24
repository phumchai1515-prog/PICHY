// Domain models — mirror of the native PICHY app, adapted for the web.
// Dates are stored as 'YYYY-MM-DD' strings (day granularity).

export type ShiftType = 'morning' | 'afternoon' | 'night' | 'off' | 'ot' | 'custom'

export type LeaveType = 'dayOff' | 'publicHoliday' | 'sick' | 'personal' | 'vacation'

export type TransactionKind = 'income' | 'expense'
export type TransactionSource = 'shift' | 'manual'
export type ExpenseCategory = 'food' | 'transport' | 'shopping' | 'bills' | 'other'
export type ActivityCategory = 'morningShift' | 'meeting' | 'ot' | 'personal'

export interface Shift {
  id: string
  date: string // YYYY-MM-DD
  type: ShiftType
  otHours: number
  note?: string
  leaveType?: LeaveType
}

export interface PayRates {
  morningShift: number
  afternoonShift: number
  nightShift: number
  otPerHour: number
}

export interface Transaction {
  id: string
  date: string
  amount: number // positive income, negative expense
  title: string
  category: string
  kind: TransactionKind
  source: TransactionSource
  shiftType?: ShiftType
  note?: string
}

export interface Activity {
  id: string
  date: string
  time: string // HH:mm
  title: string
  category: ActivityCategory
  note?: string
}

export interface UserProfile {
  name: string
  role: string
  hospital: string
}

export type ReminderLead = 30 | 60 | 120 | 180 | 300 | 480 | 720

export interface AppSettings {
  shiftReminder: boolean
  reminderLead: ReminderLead
  nightlySummary: boolean
}

export interface LeaveQuota {
  sick: number
  personal: number
  vacation: number
}

export const DEFAULT_RATES: PayRates = {
  morningShift: 1200,
  afternoonShift: 1200,
  nightShift: 1500,
  otPerHour: 250,
}

export const DEFAULT_SETTINGS: AppSettings = {
  shiftReminder: true,
  reminderLead: 300,
  nightlySummary: true,
}

export const DEFAULT_QUOTA: LeaveQuota = { sick: 30, personal: 10, vacation: 10 }

export const DEFAULT_PROFILE: UserProfile = { name: '', role: '', hospital: '' }
