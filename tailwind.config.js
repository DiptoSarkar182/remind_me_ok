// module.exports = {
//   content: [
//     './app/views/**/*.html.erb',
//     './app/helpers/**/*.rb',
//     './app/assets/stylesheets/**/*.css',
//     './app/javascript/**/*.js',
//   ],
//   plugins: [require("tailgrids/plugin")],
// }

const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [require("tailgrids/plugin")],
}