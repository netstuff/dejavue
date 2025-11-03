import { defineConfig } from 'vite';
import { resolve } from 'path';
import vue from '@vitejs/plugin-vue';
import tailwindcss from '@tailwindcss/vite';
import Components from 'unplugin-vue-components/vite'
import RekaResolver from 'reka-ui/resolver'

export default defineConfig({
  root: resolve('./frontend'),
  base: '/static/',
  plugins: [
    vue(),
    tailwindcss(),
    Components({
      dts: true,
      resolvers: [
        RekaResolver({ prefix: '' }),
      ],
    }),
  ],
  build: {
    outDir: resolve('./dejavue/static/dist'),
    assetsDir: '',
    manifest: true,
    emptyOutDir: true,
    rollupOptions: {
      // Overwrite default .html entry to main.ts in the static directory
      input: resolve('./frontend/main.ts'),
    },
  },
});
