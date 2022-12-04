const fetch = require('node-fetch')

function endCommand(client) {
  client.on('interactionCreate', async (interaction) => {
    if (!interaction.isChatInputCommand()) return

    const nowDate = new Date()
    if (interaction.commandName === 'end') {
      fetch('https://stup.fly.dev/api/discord_study_time_records', {
        method: 'PATCH',
        body: JSON.stringify({
          uid: interaction.user.id,
          ended_at: nowDate.toLocaleString()
        }),

        headers: {
          'Content-Type': 'application/json'
        }
      })
        .then((response) => {
          return response.json()
        })
        .then((data) => {
          interaction.reply(data.message)
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  })
}

module.exports = endCommand
