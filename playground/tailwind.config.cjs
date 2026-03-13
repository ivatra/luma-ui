/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './index.html',
    './src/**/*.{vue,js,ts,jsx,tsx}',
    './node_modules/luma-vue/dist/theme/*.{js,ts,json}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
