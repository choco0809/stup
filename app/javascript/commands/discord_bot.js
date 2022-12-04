const { Client, GatewayIntentBits } = require('discord.js')
const client = new Client({ intents: [GatewayIntentBits.Guilds] })
const start_command = require('./start_command.js')

client.on('ready', () => {
  console.log(`Logged in as ${client.user.tag}!`)
})

start_command(client)

client.on('interactionCreate', async (interaction) => {
  if (!interaction.isChatInputCommand()) return

  if (interaction.commandName === 'end') {
    await interaction.reply('学習時間の記録を終了します。')
  }
})

// client.login(process.env.DISCORD_BOT_TOKEN)
client.login('MTAzMzMzNTQxNDU4MjQyMzU1Mg.GAT6Q5.5jCyOoKufmbiuzMlBvdUrdMyoRckzxsCAP7DcM')
