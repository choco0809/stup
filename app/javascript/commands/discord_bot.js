const { Client, GatewayIntentBits } = require('discord.js')
const client = new Client({ intents: [GatewayIntentBits.Guilds] })
const fetch = require('node-fetch')

client.on('ready', () => {
  console.log(`Logged in as ${client.user.tag}!`)
})

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
        if (data.message === 'unregistered') {
          interaction.reply('ユーザーが未登録です。')
        }
        return data
      })
      .then((data) => {
        if (data.message === 'not ended') {
          interaction.reply('前回の学習記録が終了していません。')
        }
        return data
      })
      .then((data) => {
        if (data.message === 'registration succeeded') {
          interaction.reply('学習の記録を開始しました。')
        }
      })
      .catch((error) => {
        console.warn(error)
      })
  }
})

client.on('interactionCreate', async (interaction) => {
  if (!interaction.isChatInputCommand()) return

  if (interaction.commandName === 'end') {
    await interaction.reply('学習時間の記録を終了します。')
  }
})

client.login(process.env.DISCORD_BOT_TOKEN)
