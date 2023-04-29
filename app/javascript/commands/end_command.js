const fetch = require('node-fetch')
const { truncateSeconds } = require('./common')

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
        .then((response) => response.json())
        .then((data) =>
          interaction.reply({ content: data.message, ephemeral: true })
        )
        .catch((error) => {
          console.warn(error)
        })
    }
  })
}

module.exports = endCommand
