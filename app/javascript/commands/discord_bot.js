const { Client, GatewayIntentBits } = require('discord.js')

const setupCommands = (client) => {
  const startCommand = require('./start_command.js')
  const endCommand = require('./end_command.js')

  startCommand(client)
  endCommand(client)
}

const runBot = () => {
  const client = new Client({ intents: [GatewayIntentBits.Guilds] })

  client.on('ready', () => {
    console.log(`Logged in as ${client.user.tag}!`)
  })

  setupCommands(client)
  client.login(process.env.DISCORD_BOT_TOKEN)
}

runBot()
