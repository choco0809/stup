<script>
import { toast } from 'vue3-toastify'
import 'vue3-toastify/dist/index.css'

export default function () {
  const closeMinutes = 5000

  const successToast = (message) => {
    toast.success(message,{
      autoClose: closeMinutes,
      position: toast.POSITION.TOP_RIGHT
    })
  }

  const errorToast = (message) => {
    toast.error(message,{
      autoClose: closeMinutes,
      position: toast.POSITION.TOP_RIGHT
    })
  }

  return {
    successToast,
    errorToast,
  }

}
</script>
