const fetch = require('node-fetch')

function startCommand(client) {
  client.on('interactionCreate', async (interaction) => {
    if (!interaction.isChatInputCommand()) return

    if (interaction.commandName === 'start') {
      fetch('https://stup.fly.dev/api/discord/study_time_record', {
        method: 'POST',
        body: JSON.stringify({
          uid: interaction.user.id,
          started_at: new Date()
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

module.exports = startCommand
