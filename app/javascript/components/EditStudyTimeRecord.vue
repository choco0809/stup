<template>
  <div class="text-center">
    <div class="flex justify-center p-2">
      <div class="text-center w-1/3">開始時間</div>
      <div class="w-2/3">
        <VueTimepicker
          id="startAt"
          v-model="startedAtObject"
          class="float-left"
          name="startAt"
          input-class="form-control"
          manual-input
          hide-dropdown />
      </div>
    </div>
    <div class="flex justify p-2">
      <div class="text-center w-1/3">終了時間</div>
      <div class="w-2/3">
        <VueTimepicker
          id="endAt"
          v-model="endedAtObject"
          class="float-left"
          name="endAt"
          input-class="form-control"
          manual-input
          hide-dropdown />
      </div>
    </div>
    <div class="flex justify p-2">
      <div class="text-center w-1/3">内容</div>
      <input
        v-model="memoContent"
        name="memoContent"
        class="border border-base-300 w-2/3 h-9 w-96 pl-2.5"
        placeholder="メモの内容" />
    </div>
    <div v-if="errorStartedAtMessage === '開始時間を入力してください'">
      <p class="text-red-500 py-2">{{ errorStartedAtMessage }}</p>
    </div>
    <div v-if="errorEndedAtMessage === '終了時間を入力してください'">
      <p class="text-red-500 py-2">{{ errorEndedAtMessage }}</p>
    </div>
    <div v-if="errorMemoMessage === '20文字以内で入力してください'">
      <p class="text-red-500 py-2">{{ errorMemoMessage }}</p>
    </div>
    <div class="flex justify-center p-2">
      <div class="pr-2">
        <button
          id="editStudyRecordButton"
          class="btn btn-info"
          :disabled="isAbleCreateButton"
          @click="editStudyTimeRecord()"
        >
          保存
        </button>
      </div>
      <div>
        <button class="btn btn-info" @click="cancelEditModal()">
          キャンセル
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import VueTimepicker from 'vue3-timepicker/src/VueTimepicker.vue'
import useValidateModal from './functions/UseValidateModal.vue'
import useStudyTimeRecordFunction from './functions/UseStudyTimeRecordFunction.vue'
import { useStore } from 'vuex'
import { ref, onMounted } from 'vue'

export default {
  name: 'EditStudyTimeRecord',
  components: {
    VueTimepicker
  },
  props: {
    date: {
      type: Number,
      require: true,
      default: 0
    }
  },
  setup(props) {
    const {
      startedAtObject,
      endedAtObject,
      memoContent,
      errorStartedAtMessage,
      errorEndedAtMessage,
      errorMemoMessage,
      isAbleCreateButton
    } = useValidateModal()

    const { token, createNewDate, compareStartedAtAndEndedAt } = useStudyTimeRecordFunction()
    const store = useStore()
    const recordId = ref()
    const startedAt = ref()
    const endedAt = ref()
    const memo = ref()

    const cancelEditModal = () => {
      store.commit('closeEditStudyRecordModal')
    }

    const convertHoursToString = (date) => {
      return new Date(date).getHours().toString().padStart(2, '0')
    }

    const convertMinutesToString = (date) => {
      return new Date(date).getMinutes().toString().padStart(2, '0')
    }

    const fetchEditStudyTimeRecord = () => {
      fetch(`/api/study_time_records/${recordId.value}`, {
        method: 'PUT',
        body: JSON.stringify({
          started_at: startedAt.value,
          ended_at: endedAt.value,
          memo: memo.value
        }),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': token()
        },
        credentials: 'same-origin'
      })
          .then((response) => {
            return response.json()
          })
          .then((json) => {
            let monthlyStudyTime = store.getters.monthlyStudyTime
            const updateElementNo = monthlyStudyTime.findIndex(({ id }) => id === recordId.value)
            monthlyStudyTime[updateElementNo] = json
            store.commit('updateMonthlyStudyTime', {monthlyStudyTime: monthlyStudyTime})
            store.commit('closeEditStudyRecordModal')
          })
          .catch((error) => {
            console.warn(error)
          })
    }

    const editStudyTimeRecord = () => {
      startedAt.value = createNewDate(
          store.state.calendarYear,
          store.state.calendarMonth,
          props.date,
          startedAtObject.value.HH,
          startedAtObject.value.mm
      )
      endedAt.value = createNewDate(
          store.state.calendarYear,
          store.state.calendarMonth,
          props.date,
          endedAtObject.value.HH,
          endedAtObject.value.mm
      )
      endedAt.value = compareStartedAtAndEndedAt(startedAt.value, endedAt.value)
      memo.value = memoContent.value
      fetchEditStudyTimeRecord()
    }

    onMounted(() => {
      recordId.value = store.getters.editStudyTimeRecord.id
      const editStartedAt = store.getters.editStudyTimeRecord.startedAt
      const editEndedAt = store.getters.editStudyTimeRecord.endedAt
      const editMemo = store.getters.editStudyTimeRecord.memo
      startedAtObject.value = {
        HH: convertHoursToString(editStartedAt),
        mm: convertMinutesToString(editStartedAt)
      }
      endedAtObject.value = {
        HH: convertHoursToString(editEndedAt),
        mm: convertMinutesToString(editEndedAt)
      }
      memoContent.value = editMemo
    })

    return {
      startedAtObject,
      endedAtObject,
      memoContent,
      errorStartedAtMessage,
      errorEndedAtMessage,
      errorMemoMessage,
      isAbleCreateButton,
      cancelEditModal,
      editStudyTimeRecord
    }
  }
}
</script>
