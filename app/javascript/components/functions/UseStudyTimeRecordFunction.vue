<script>
export default function () {
  const token = () => {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.getAttribute('content') : ''
  }

  const formatHours = (hours) => {
    return hours.toString().padStart(2, '0')
  }

  const formatMinutes = (minutes) => {
    return minutes.toString().padStart(2, '0')
  }

  const formatDay = (day) => {
    return day.toString().padStart(2, '0')
  }

  const formatMonth = (month) => {
    return month.toString().padStart(2, '0')
  }

  const createNewDate = (year, month, date, hh, mm) => {
    return new Date(year, month - 1, date, hh, mm)
  }

  const compareStartedAtAndEndedAt = (startAt, endAt) => {
    if (startAt - endAt < 0) return endAt
    endAt.setDate(endAt.getDate() + 1)
    return endAt
  }

  const createStartAndEndDate = (calendarYear, calendarMonth, date, atObject) => {
    return createNewDate(
        calendarYear,
        calendarMonth,
        date,
        atObject.value.HH,
        atObject.value.mm
    )
  }

  return {
    token,
    formatHours,
    formatMinutes,
    formatDay,
    formatMonth,
    createNewDate,
    compareStartedAtAndEndedAt,
    createStartAndEndDate
  }
}
</script>
