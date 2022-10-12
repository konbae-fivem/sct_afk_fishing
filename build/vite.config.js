import { defineConfig } from "vite";
import { viteObfuscateFile } from "vite-plugin-obfuscator";

import vue from "@vitejs/plugin-vue";

// https://vitejs.dev/config/
export default defineConfig({
  base: process.env.NODE_ENV === "production" ? "./" : "/",
  plugins: [vue(), viteObfuscateFile()],
  server: {
    watch: {
      usePolling: true,
    },
  },
});
