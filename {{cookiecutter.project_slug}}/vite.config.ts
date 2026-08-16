import { defineConfig } from "vite";
import { resolve } from "path";
{% if cookiecutter.frontend == "vue" -%}
import vue from "@vitejs/plugin-vue";
{% elif cookiecutter.frontend == "react" -%}
import react from "@vitejs/plugin-react";
{% endif -%}
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  root: resolve("./frontend"),
  base: "/static/",
  plugins: [
    {%- if cookiecutter.frontend == "vue" %}
    vue(),
    {%- elif cookiecutter.frontend == "react" %}
    react(),
    {%- endif %}
    tailwindcss(),
  ],
  build: {
    outDir: resolve("./staticfiles/dist"),
    assetsDir: "",
    manifest: "manifest.json",
    emptyOutDir: true,
    rollupOptions: {
      input: resolve("./frontend/main.{{ "tsx" if cookiecutter.frontend == "react" else "ts" }}"),
    },
  },
});
