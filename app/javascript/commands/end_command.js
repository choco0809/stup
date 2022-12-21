const fetch = require('node-fetch')

function endCommand(client) {
  client.on('interactionCreate', async (interaction) => {
    if (!interaction.isChatInputCommand()) return

    if (interaction.commandName === 'end') {
      fetch('https://stup.fly.dev/api/discord/study_time_record', {
        method: 'PATCH',
        body: JSON.stringify({
          uid: interaction.user.id,
          ended_at: new Date()
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
