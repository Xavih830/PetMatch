/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#F26419', // Coral
          dark: '#D15212',
          light: '#FF7F3B',
        },
        secondary: {
          DEFAULT: '#2EC4B6', // Teal
          dark: '#25A296',
          light: '#5AD3C7',
        },
        crema: '#FDF8F2',
        carbon: '#2D2D2D',
        success: '#10B981',
        warning: '#F59E0B',
        error: '#EF4444',
      },
      fontFamily: {
        poppins: ['Poppins', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
