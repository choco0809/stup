module.exports = {
  content: [
    './app/views/**/*.html.slim',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.{js,vue}'
  ],
  theme: {
    extend: {
      colors: {
        header: '#9ac5e5',
        footer: '#edce7a'
      },
      spacing: {
        '102' : '28rem',
        '118' : '32rem',
        '134' : '36rem'
      }
    }
  },
  plugins: [require('daisyui')],
  daisyui: {
    themes: ["cmyk"]
  }
}
