// Display metadata + colors for shift / leave / category types.
import type {
  ShiftType,
  LeaveType,
  ExpenseCategory,
  ActivityCategory,
} from './types'

interface ShiftMeta {
  label: string
  shortChip: string
  timeRange: string
  start?: { hour: number; minute: number }
  dot: string
  text: string
  tint: string
}

export const SHIFT_META: Record<ShiftType, ShiftMeta> = {
  morning: { label: 'เช้า', shortChip: 'ช', timeRange: '08:00–16:00', start: { hour: 8, minute: 0 }, dot: '#EBA63F', text: '#A77B23', tint: '#FAEBD3' },
  afternoon: { label: 'บ่าย', shortChip: 'บ', timeRange: '16:00–24:00', start: { hour: 16, minute: 0 }, dot: '#43B0A0', text: '#1C8275', tint: '#DFF1ED' },
  night: { label: 'ดึก', shortChip: 'ด', timeRange: '00:00–08:00', start: { hour: 0, minute: 0 }, dot: '#7E6EE0', text: '#6151C9', tint: '#EBE6FA' },
  off: { label: 'วันหยุด', shortChip: 'พัก', timeRange: 'ไม่มีเวร', dot: '#329F61', text: '#329F61', tint: '#E6F2E8' },
  ot: { label: 'OT', shortChip: 'OT', timeRange: 'ตามเวร', start: { hour: 8, minute: 0 }, dot: '#EC6E95', text: '#CE5079', tint: '#FAE3EB' },
  custom: { label: 'อื่นๆ', shortChip: '+', timeRange: 'กำหนดเอง', dot: '#F0936A', text: '#D9683B', tint: '#FBEDE4' },
}

interface LeaveMeta {
  label: string
  shortLabel: string
  icon: string // emoji
  color: string
  tint: string
  hasQuota: boolean
}

export const LEAVE_META: Record<LeaveType, LeaveMeta> = {
  dayOff: { label: 'วันหยุด', shortLabel: 'พัก', icon: '☕️', color: '#329F61', tint: '#E6F2E8', hasQuota: false },
  publicHoliday: { label: 'วันหยุดนักขัตฤกษ์', shortLabel: 'นักขัตฤกษ์', icon: '🚩', color: '#E5894B', tint: '#FBEAD9', hasQuota: false },
  sick: { label: 'ลาป่วย', shortLabel: 'ป่วย', icon: '🏥', color: '#CE5079', tint: '#FAE3EB', hasQuota: true },
  personal: { label: 'ลากิจ', shortLabel: 'กิจ', icon: '🧍', color: '#7E6EE0', tint: '#EBE6FA', hasQuota: true },
  vacation: { label: 'ลาพักร้อน', shortLabel: 'พักร้อน', icon: '🏖️', color: '#43B0A0', tint: '#DFF1ED', hasQuota: true },
}

export const QUOTA_KINDS: LeaveType[] = ['sick', 'personal', 'vacation']

export const EXPENSE_META: Record<ExpenseCategory, { label: string; icon: string }> = {
  food: { label: 'อาหาร', icon: '🍽️' },
  transport: { label: 'เดินทาง', icon: '🚗' },
  shopping: { label: 'ช้อปปิ้ง', icon: '🛒' },
  bills: { label: 'บิล', icon: '🧾' },
  other: { label: 'อื่นๆ', icon: '•••' },
}

export const ACTIVITY_META: Record<ActivityCategory, { label: string; icon: string; color: string; tint: string }> = {
  morningShift: { label: 'งานเวร', icon: '🩺', color: '#EBA63F', tint: '#FAEBD3' },
  meeting: { label: 'ประชุม', icon: '👥', color: '#43B0A0', tint: '#DFF1ED' },
  ot: { label: 'OT', icon: '⏱️', color: '#EC6E95', tint: '#FAE3EB' },
  personal: { label: 'ส่วนตัว', icon: '❤️', color: '#7E6EE0', tint: '#EBE6FA' },
}

export const REMINDER_LABELS: Record<number, string> = {
  30: '30 นาที',
  60: '1 ชั่วโมง',
  120: '2 ชั่วโมง',
  180: '3 ชั่วโมง',
  300: '5 ชั่วโมง',
  480: '8 ชั่วโมง',
  720: '12 ชั่วโมง',
}
