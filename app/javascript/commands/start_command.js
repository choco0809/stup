const fetch = require('node-fetch')
const { truncateSeconds } = require('./common')

function startCommand(client) {
  client.on('interactionCreate', async (interaction) => {
    if (!interaction.isChatInputCommand()) return

    const studyRecordsMemo = interaction.options.getString('メモ') || ''
    if (!validateLength(studyRecordsMemo)) {
      return interaction.reply({
        content: 'メモは20文字以内で記入してください🙅',
        ephemeral: true
      })
    }

    if (interaction.commandName === 'start') {
      fetch('https://stup.fly.dev/api/discord/study_time_record', {
        method: 'POST',
        body: JSON.stringify({
          uid: interaction.user.id,
          started_at: truncateSeconds(new Date()),
          memo: studyRecordsMemo
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

function validateLength(value) {
  return value.length <= 20
}

module.exports = startCommand
