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

  return {
    token,
    formatHours,
    formatMinutes
  }
}
</script>
