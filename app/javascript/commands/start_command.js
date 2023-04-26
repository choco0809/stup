const fetch = require('node-fetch')

function startCommand(client) {
  client.on('interactionCreate', async (interaction) => {
    if (!interaction.isChatInputCommand()) return
    let studyRecordsMemo = ''
    if (interaction.options.getString('メモ') !== null) {
      studyRecordsMemo = interaction.options.getString('メモ')
      if (!validateLength(studyRecordsMemo)) {
        return interaction.reply({
          content: 'メモは20文字以内で記入してください🙅',
          ephemeral: true
        })
      }
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

function validateLength(value) {
  return value.length <= 20 ? true : false
}

function truncateSeconds(date) {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  const hours = date.getHours()
  const minutes = date.getMinutes()
  return new Date(`${year}/${month}/${day} ${hours}:${minutes}`)
}

module.exports = startCommand
