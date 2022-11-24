const { REST, Routes } = require('discord.js')

const commands = [
  {
    name: 'start',
    description: '学習時間の記録を開始します。'
  },
  {
    name: 'end',
    description: '学習時間の記録を終了します。'
  }
]

const rest = new REST({ version: '10' }).setToken(process.env.DISCORD_BOT_TOKEN)

;(async () => {
  try {
    console.log('Started refreshing application (/) commands.')

    await rest.put(Routes.applicationCommands(process.env.DISCORD_CLIENT_ID), {
      body: commands
    })

    console.log('Successfully reloaded application (/) commands.')
  } catch (error) {
    console.error(error)
  }
})()
