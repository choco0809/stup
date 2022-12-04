const fetch = require('node-fetch')

function start_command(client) {
  client.on('interactionCreate', async (interaction) => {
    if (!interaction.isChatInputCommand()) return

    if (interaction.commandName === 'start') {
      fetch('http://localhost:3000/api/study_time_records', {
        method: 'POST',
        body: JSON.stringify({ uid: interaction.user.id }),
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

module.exports = start_command
