module.exports = {
  content: [
    './app/views/**/*.html.slim',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        header: '#9ac5e5',
        footer: '#edce7a'
      }
    }
  },
  plugins: [require('daisyui')],
  daisyui: {
    themes: ["cmyk"]
  }
}
