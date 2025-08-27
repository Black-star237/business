import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";
import { componentTagger } from "lovable-tagger";
import { VitePWA } from "vite-plugin-pwa";

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => ({
  base: './',
  server: {
    host: "::",
    port: 8080,
  },
  plugins: [
    react(),
    mode === 'development' &&
    componentTagger(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.ico', 'robots.txt', 'apple-touch-icon.png'],
      workbox: {
        maximumFileSizeToCacheInBytes: 4 * 1024 * 1024, // 4MB limit instead of 2MB
        globPatterns: ['**/*.{js,css,html,ico,png,svg,jpg,jpeg}']
      },
      manifest: {
        name: 'FluxiaBiz',
        short_name: 'FluxiaBiz',
        description: 'Solution ERP complète pour PME avec IA intégrée',
        theme_color: '#0f172a',
        background_color: '#f8fafc',
        display: 'standalone',
        icons: [
          {
            src: 'pwa-192x192.png',
            sizes: '192x192',
            type: 'image/png',
          },
          {
            src: 'pwa-512x512.png',
            sizes: '512x512',
            type: 'image/png',
          },
          {
            src: 'pwa-512x512.png',
            sizes: '512x512',
            type: 'image/png',
            purpose: 'any maskable',
          }
        ]
      }
    }),
  ].filter(Boolean),
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  build: {
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, 'src/main.tsx'),
      },
      output: {
        manualChunks: {
          // Separate heavy markdown dependencies
          'markdown-vendor': ['react-markdown', 'remark-gfm', 'react-syntax-highlighter'],
          // Separate UI components
          'ui-vendor': ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu', '@radix-ui/react-scroll-area'],
          // Keep React separately  
          'react-vendor': ['react', 'react-dom']
        }
      }
    },
    chunkSizeWarningLimit: 1000 // Increase warning limit to 1MB
  }
}));
