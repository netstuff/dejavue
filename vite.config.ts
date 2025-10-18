import { defineConfig } from 'vite';
import { resolve } from 'path';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  root: resolve('./dejavue/static/spa'),
  base: '/static/',
  plugins: [vue()],
  build: {
    outDir: resolve('./dejavue/static/dist'),
    assetsDir: '',
    manifest: true,
    emptyOutDir: true,
    rollupOptions: {
      // Overwrite default .html entry to main.ts in the static directory
      input: resolve('./dejavue/static/spa/main.ts'),
    },
  },
});
