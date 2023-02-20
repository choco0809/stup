<script>
import { toast } from 'vue3-toastify'
import 'vue3-toastify/dist/index.css'

export default function () {
  const closeMinutes = 5000

  const success = (message) => {
    toast.success(message,{
      autoClose: closeMinutes,
      position: toast.POSITION.TOP_RIGHT
    })
  }

  return {
    success
  }

}
</script>
