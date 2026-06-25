import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import type {
  Shift, Transaction, Activity, PayRates, UserProfile, AppSettings, LeaveQuota, LeaveType,
} from './types'
import {
  DEFAULT_RATES, DEFAULT_SETTINGS, DEFAULT_QUOTA, DEFAULT_PROFILE,
} from './types'
import { uid } from './domain'
import { fromKey, toKey } from './utils/thaiDate'

interface AppState {
  shifts: Shift[]
  transactions: Transaction[] // manual only; shift income is derived in selectors
  activities: Activity[]
  rates: PayRates
  profile: UserProfile
  settings: AppSettings
  quota: LeaveQuota
  hasOnboarded: boolean

  upsertShift: (shift: Shift) => void
  deleteShift: (id: string) => void
  setLeaveRange: (start: string, end: string, leaveType: LeaveType) => void
  addActivity: (a: Activity) => void
  deleteActivity: (id: string) => void
  addTransaction: (t: Transaction) => void
  deleteTransaction: (id: string) => void
  updateRates: (r: PayRates) => void
  updateSettings: (s: AppSettings) => void
  updateQuota: (q: LeaveQuota) => void
  updateProfile: (p: UserProfile) => void
  completeOnboarding: (profile: UserProfile, rates: PayRates) => void
  resetAll: () => void
}

export const useStore = create<AppState>()(
  persist(
    (set) => ({
      shifts: [],
      transactions: [],
      activities: [],
      rates: DEFAULT_RATES,
      profile: DEFAULT_PROFILE,
      settings: DEFAULT_SETTINGS,
      quota: DEFAULT_QUOTA,
      hasOnboarded: false,

      upsertShift: (shift) =>
        set((s) => ({
          shifts: [...s.shifts.filter((x) => x.id !== shift.id), shift].sort((a, b) =>
            a.date < b.date ? -1 : 1,
          ),
        })),

      deleteShift: (id) => set((s) => ({ shifts: s.shifts.filter((x) => x.id !== id) })),

      setLeaveRange: (start, end, leaveType) =>
        set((s) => {
          const lo = start <= end ? start : end
          const hi = start <= end ? end : start
          const days: string[] = []
          let cur = fromKey(lo)
          const last = fromKey(hi)
          while (cur <= last) {
            days.push(toKey(cur))
            cur = new Date(cur.getFullYear(), cur.getMonth(), cur.getDate() + 1)
          }
          const kept = s.shifts.filter((sh) => !days.includes(sh.date))
          const added: Shift[] = days.map((d) => ({ id: uid(), date: d, type: 'off', otHours: 0, leaveType }))
          return { shifts: [...kept, ...added].sort((a, b) => (a.date < b.date ? -1 : 1)) }
        }),

      addActivity: (a) =>
        set((s) => ({
          activities: [...s.activities, a].sort((x, y) =>
            x.date === y.date ? (x.time < y.time ? -1 : 1) : x.date < y.date ? -1 : 1,
          ),
        })),

      deleteActivity: (id) => set((s) => ({ activities: s.activities.filter((x) => x.id !== id) })),

      addTransaction: (t) =>
        set((s) => ({ transactions: [...s.transactions, t].sort((a, b) => (a.date > b.date ? -1 : 1)) })),

      deleteTransaction: (id) => set((s) => ({ transactions: s.transactions.filter((x) => x.id !== id) })),

      updateRates: (rates) => set({ rates }),
      updateSettings: (settings) => set({ settings }),
      updateQuota: (quota) => set({ quota }),
      updateProfile: (profile) => set({ profile }),

      completeOnboarding: (profile, rates) => set({ profile, rates, hasOnboarded: true }),

      resetAll: () =>
        set({
          shifts: [], transactions: [], activities: [],
          rates: DEFAULT_RATES, profile: DEFAULT_PROFILE,
          settings: DEFAULT_SETTINGS, quota: DEFAULT_QUOTA, hasOnboarded: false,
        }),
    }),
    {
      name: 'pichy-store-v1',
      version: 1,
      storage: createJSONStorage(() => localStorage),
      // Persist only data, never the action functions.
      partialize: (s) => ({
        shifts: s.shifts,
        transactions: s.transactions,
        activities: s.activities,
        rates: s.rates,
        profile: s.profile,
        settings: s.settings,
        quota: s.quota,
        hasOnboarded: s.hasOnboarded,
      }),
    },
  ),
)
