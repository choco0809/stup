<script>
import { useField } from 'vee-validate'
import { computed } from 'vue'

export default function () {
  const validateStartedAt = () => {
    if (startedAtObject === undefined || startedAtObject.value === undefined)
      return false
    if (startedAtObject.value.HH === '' || startedAtObject.value.mm === '')
      return '開始時間を入力してください'
    return true
  }

  const validateEndedAt = () => {
    if (endedAtObject === undefined || endedAtObject.value === undefined)
      return false
    if (endedAtObject.value.HH === '' || endedAtObject.value.mm === '')
      return '終了時間を入力してください'
    return true
  }

  const validateMemo = () => {
    if (memoContent.value === undefined || memoContent.value === null)
      return true
    if (memoContent.value.length > 20) return '20文字以内で入力してください'
    return true
  }

  const {
    value: startedAtObject = { HH: null, mm: null },
    errorMessage: errorStartedAtMessage
  } = useField('startAt', validateStartedAt)

  const {
    value: endedAtObject = { HH: null, mm: null },
    errorMessage: errorEndedAtMessage
  } = useField('endAt', validateEndedAt)

  const { value: memoContent, errorMessage: errorMemoMessage } = useField(
    'memoContent',
    validateMemo
  )

  const isAbleCreateButton = computed(() => {
    if (
      validateStartedAt() === true &&
      validateEndedAt() === true &&
      validateMemo() === true
    )
      return false
    return true
  })

  return {
    errorStartedAtMessage,
    errorEndedAtMessage,
    errorMemoMessage,
    isAbleCreateButton,
    startedAtObject,
    endedAtObject,
    memoContent
  }
}
</script>
