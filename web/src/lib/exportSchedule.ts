import type { Shift, PayRates, UserProfile } from '../types'
import { shiftIncome, resolvedLeave } from '../domain'
import { SHIFT_META, LEAVE_META } from '../meta'
import { baht } from '../utils/money'
import { dateLabelMedium, monthYearLong, sameMonth, toKey } from '../utils/thaiDate'

// Renders the month's schedule into a print window. We use the browser's
// print-to-PDF (rather than jsPDF) so Thai text renders with system fonts.
export function exportSchedule(month: Date, shifts: Shift[], rates: PayRates, profile: UserProfile) {
  const monthKey = toKey(month)
  const rows = shifts
    .filter((s) => sameMonth(s.date, monthKey))
    .sort((a, b) => (a.date < b.date ? -1 : 1))

  let total = 0
  const body = rows.map((s) => {
    const income = shiftIncome(s, rates)
    total += income
    const leave = resolvedLeave(s)
    const type = leave ? LEAVE_META[leave].label : `เวร${SHIFT_META[s.type].label}${s.otHours > 0 ? ` + OT ${s.otHours} ชม.` : ''}`
    return `<tr><td>${dateLabelMedium(s.date)}</td><td>${type}</td><td class="r">${income > 0 ? baht(income) : '—'}</td></tr>`
  }).join('')

  const who = [profile.name, profile.role, profile.hospital].filter(Boolean).join(' · ')
  const html = `<!doctype html><html lang="th"><head><meta charset="utf-8"><title>ตารางเวร ${monthYearLong(month)}</title>
  <style>
    body{font-family:-apple-system,'Noto Sans Thai',sans-serif;color:#2E2A28;padding:32px;}
    h1{color:#E8743F;font-size:22px;margin:0 0 4px;}
    .who{color:#666;font-size:13px;margin-bottom:20px;}
    table{width:100%;border-collapse:collapse;font-size:13px;}
    th,td{text-align:left;padding:8px 6px;border-bottom:1px solid #eee;}
    th{color:#999;font-size:12px;}
    .r{text-align:right;}
    tfoot td{font-weight:700;border-top:2px solid #ddd;border-bottom:none;}
  </style></head><body>
  <h1>ตารางเวร ${monthYearLong(month)}</h1>
  <div class="who">${who}</div>
  <table>
    <thead><tr><th>วันที่</th><th>ประเภท</th><th class="r">รายได้</th></tr></thead>
    <tbody>${body || '<tr><td colspan="3">ไม่มีเวรในเดือนนี้</td></tr>'}</tbody>
    <tfoot><tr><td>รวม ${rows.length} เวร</td><td></td><td class="r">${baht(total)}</td></tr></tfoot>
  </table>
  <script>window.onload=function(){setTimeout(function(){window.print()},300)}</script>
  </body></html>`

  const w = window.open('', '_blank')
  if (!w) { alert('กรุณาอนุญาต popup เพื่อส่งออก PDF'); return }
  w.document.write(html)
  w.document.close()
}
