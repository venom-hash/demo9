import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig(async () => {
  const plugins = [react(), tailwindcss()];
  
  // Only load source-tags plugin in development
  if (process.env.NODE_ENV !== 'production') {
    try {
      // @ts-ignore
      const m = await import('./.vite-source-tags.js');
      plugins.push(m.sourceTags());
    } catch {}
  }
  
return { 
    plugins,
    base: './',
    build: {
      rollupOptions: {
        output: {
          manualChunks: {
            react: ['react', 'react-dom', 'react-router-dom'],
            supabase: ['@supabase/supabase-js'],
            motion: ['framer-motion'],
            icons: ['lucide-react']
          }
        }
      }
    }
  };
})
