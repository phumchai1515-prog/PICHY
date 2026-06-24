import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

// GitHub Pages project site is served from /<repo>/. Change this if the repo
// name is not "PICHY".
const base = '/PICHY/'

export default defineConfig({
  base,
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['mascot-full.svg', 'mascot-head.svg', 'favicon.svg'],
      manifest: {
        name: 'PICHY — ตารางเวรพยาบาล',
        short_name: 'PICHY',
        description: 'จัดการตารางเวร คำนวณรายได้ และบันทึกรายรับรายจ่ายสำหรับพยาบาล',
        lang: 'th',
        theme_color: '#EC7E54',
        background_color: '#FBF6F1',
        display: 'standalone',
        orientation: 'portrait',
        start_url: base,
        scope: base,
        icons: [
          { src: 'icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: 'icon-512.png', sizes: '512x512', type: 'image/png' },
          { src: 'icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
        ],
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,svg,png,woff2}'],
      },
    }),
  ],
})
