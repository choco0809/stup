function truncateSeconds(date) {
  date.setSeconds(0)
  return date
}

module.exports = {
  truncateSeconds
}
