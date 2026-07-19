import { defineConfig } from "vite";
import { resolve } from "path";
import vue from "@vitejs/plugin-vue";

// TODO: wrap with cookiecutter option
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  root: resolve("./frontend"),
  base: "/static/",
  plugins: [vue(), tailwindcss()],
  build: {
    outDir: resolve("./staticfiles/dist"),
    assetsDir: "",
    manifest: "manifest.json",
    emptyOutDir: true,
    rollupOptions: {
      // Overwrite default .html entry to main.ts in the static directory
      input: resolve("./frontend/main.ts"),
    },
  },
});
