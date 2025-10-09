module.exports = {
  content: [
    './js/**/*.{js,jsx,ts,tsx}',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
  ],
  theme: {
    extend: {
      colors: {
        brand: '#FD4F00',
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}