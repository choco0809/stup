const fetch = require('node-fetch')

function startCommand(client) {
  client.on('interactionCreate', async (interaction) => {
    if (!interaction.isChatInputCommand()) return

    const nowDate = new Date()
    if (interaction.commandName === 'start') {
      fetch('http://localhost:3000/api/discord_study_time_records', {
        method: 'POST',
        body: JSON.stringify({
          uid: interaction.user.id,
          started_at: nowDate.toLocaleString()
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
