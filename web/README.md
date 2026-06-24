# PICHY — PWA

เวอร์ชันเว็บ (Progressive Web App) ของ PICHY — แอปจัดการตารางเวร คำนวณรายได้
และบันทึกรายรับรายจ่ายสำหรับพยาบาล ติดตั้งลงโฮมสกรีนได้ทั้ง iOS / Android / เดสก์ท็อป
ฟรี ไม่ต้องผ่าน App Store และไม่มีวันหมดอายุ

## Stack
- React 19 + TypeScript + Vite
- Zustand (state) + `persist` → เก็บข้อมูลใน `localStorage` ของเครื่อง
- vite-plugin-pwa (service worker + manifest, ใช้งานออฟไลน์ได้)

## พัฒนา
```bash
cd web
npm install
npm run dev      # http://localhost:5173/PICHY/
npm run build    # สร้าง dist/ (PWA)
npm run preview  # ดู build จริง
```

## Deploy (GitHub Pages — ฟรี)
1. สร้าง repo ชื่อ **PICHY** บน GitHub แล้ว push โค้ดนี้ขึ้นไป
2. ใน repo → **Settings → Pages → Build and deployment → Source: GitHub Actions**
3. Workflow `.github/workflows/deploy-web.yml` จะ build `web/` และ deploy อัตโนมัติทุกครั้งที่ push
4. แอปจะอยู่ที่ `https://<username>.github.io/PICHY/`

> ถ้าตั้งชื่อ repo อื่นที่ไม่ใช่ `PICHY` ต้องแก้ `base` ใน `web/vite.config.ts` ให้ตรง

## ติดตั้งลงเครื่อง (ผู้ใช้)
- **iOS Safari:** เปิดลิงก์ → ปุ่มแชร์ → "เพิ่มไปยังหน้าจอโฮม"
- **Android Chrome:** เปิดลิงก์ → เมนู → "ติดตั้งแอป" / "เพิ่มไปยังหน้าจอหลัก"

## ข้อจำกัด
- ข้อมูลเก็บในเครื่อง (localStorage) — ไม่ซิงก์ข้ามอุปกรณ์ และถูกลบถ้าล้างข้อมูลเบราว์เซอร์
- การแจ้งเตือนเวรเป็นแบบ **ในแอป** (รายการเวรที่ใกล้ถึง) — ไม่มี push แจ้งเตือน background
  เพราะ iOS PWA จำกัด
