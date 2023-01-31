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
        class="border border-base-300 w-2/3 h-9 w-96"
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
    <button
      id="createNewStudyRecordButton"
      class="btn btn-info"
      :disabled="isAbleCreateButton"
      @click="newStudyTimeRecord()">
      作成
    </button>
  </div>
</template>

<script>
import { ref } from 'vue'
import VueTimepicker from 'vue3-timepicker/src/VueTimepicker.vue'
import { useStore } from 'vuex'
import useStudyTimeRecordFunction from './functions/UseStudyTimeRecordFunction.vue'
import useValidateModal from './functions/UseValidateModal.vue'

export default {
  name: 'CreateStudyTimeRecord',
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
    const { token } = useStudyTimeRecordFunction()
    const {
      errorStartedAtMessage,
      errorEndedAtMessage,
      errorMemoMessage,
      isAbleCreateButton,
      startedAtObject,
      endedAtObject,
      memoContent
    } = useValidateModal()

    const store = useStore()
    const startedAt = ref()
    const endedAt = ref()
    const memo = ref()

    const fetchDailyStudyTimeRecords = () => {
      fetch(`/api/study_time_records`, {
        method: 'POST',
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
          store.commit('closeShowModal')
          store.commit('closeCreateStudyRecordModal')
          store.commit('addStudyTimeRecord', { studyTimeRecord: json })
        })
        .catch((error) => {
          console.warn(error)
        })
    }

    const createNewDate = (year, month, date, hh, mm) => {
      return new Date(year, month - 1, date, hh, mm)
    }

    const compareStartedAtAndEndedAt = (startAt, endAt) => {
      if (startAt - endAt < 0) return endAt
      endAt.setDate(endAt.getDate() + 1)
      return endAt
    }

    const newStudyTimeRecord = () => {
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
      fetchDailyStudyTimeRecords()
    }

    return {
      startedAtObject,
      endedAtObject,
      memoContent,
      errorStartedAtMessage,
      errorEndedAtMessage,
      errorMemoMessage,
      isAbleCreateButton,
      newStudyTimeRecord
    }
  }
}
</script>
