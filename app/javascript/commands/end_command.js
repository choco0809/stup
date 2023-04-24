const fetch = require('node-fetch')

function endCommand(client) {
  client.on('interactionCreate', async (interaction) => {
    if (!interaction.isChatInputCommand()) return

    if (interaction.commandName === 'end') {
      fetch('https://stup.fly.dev/api/discord/study_time_record', {
        method: 'PATCH',
        body: JSON.stringify({
          uid: interaction.user.id,
          ended_at: truncateSeconds(new Date())
        }),

        headers: {
          'Content-Type': 'application/json'
        }
      })
        .then((response) => {
          return response.json()
        })
        .then((data) => {
          return interaction.reply({ content: data.message, ephemeral: true })
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  })
}

function truncateSeconds(date) {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  const hours = date.getHours()
  const minutes = date.getMinutes()
  return new Date(`${year}/${month}/${day} ${hours}:${minutes}`)
}

module.exports = endCommand
