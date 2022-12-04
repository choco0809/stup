const { Client, GatewayIntentBits } = require('discord.js')
const client = new Client({ intents: [GatewayIntentBits.Guilds] })
const startCommand = require('./start_command.js')
const endCommand = require('./end_command.js')

client.on('ready', () => {
  console.log(`Logged in as ${client.user.tag}!`)
})

startCommand(client)
endCommand(client)

client.login(process.env.DISCORD_BOT_TOKEN)
