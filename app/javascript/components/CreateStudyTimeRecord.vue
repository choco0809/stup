<template>
  <div class="text-center">
    <div class="flex justify-center p-2">
      <div class="text-center w-1/3">開始時間</div>
      <div class="w-2/3">
        <VueTimepicker
            v-model="startedAtObject"
            name="studyAt"
            input-class="form-control"
            manual-input hide-dropdown
        />
      </div>
    </div>
    <div class="flex justify-center p-2">
      <div class="text-center w-1/3">終了時間</div>
      <div class="w-2/3">
        <VueTimepicker
            v-model="endedAtObject"
            name="studyAt"
            input-class="form-control"
            manual-input hide-dropdown
        />
      </div>
    </div>
    <p class="text-red-500 py-2"> {{ errorStartedAtMessage }} </p>
    <p class="text-red-500 py-2"> {{ errorEndedAtMessage }} </p>
    <button class="btn btn-info" @click="newStudyTimeRecord()" :disabled="isAbleCreateButton" >作成</button>
  </div>
</template>

<script>
import {computed, ref} from 'vue'
import VueTimepicker from 'vue3-timepicker/src/VueTimepicker.vue'
import { useField } from 'vee-validate'
import { useStore } from 'vuex'
import store from '../store'

export default {
  name: 'CreateStudyTimeRecord',
  components: {
    VueTimepicker,
    store,
  },
  props: {
    date: {
      type: Number,
      require: true,
      default: 0
    }
  },
  setup(props) {
    const store = useStore()
    const startedAt = ref()
    const endedAt = ref()

    const validateStartedAt = () => {
      if(startedAtObject === undefined || startedAtObject.value === undefined) return false
      if(startedAtObject.value.HH === '' || startedAtObject.value.mm === '') return '開始時間を入力してください'
      return true
    }

    const validateEndedAt = () => {
      if(endedAtObject === undefined || endedAtObject.value === undefined) return false
      if(endedAtObject.value.HH === '' || endedAtObject.value.mm === '') return '終了時間を入力してください'
      return true
    }

    const { value: startedAtObject, errorMessage:errorStartedAtMessage }
        = useField('studyAt', validateStartedAt)

    const { value: endedAtObject, errorMessage:errorEndedAtMessage }
        = useField('studyAt', validateEndedAt)

    const isAbleCreateButton = computed(() => {
      if(validateStartedAt() === true && validateEndedAt() === true ) return false
      return true
    })

    const token = () => {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    }

    const fetchDailyStudyTimeRecords = () => {
      fetch(`/api/study_time_records`, {
        method: 'POST',
        body: JSON.stringify({
          started_at: startedAt.value,
          ended_at: endedAt.value
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
            store.commit('addStudyTimeRecord', {studyTimeRecord: json})
          })
          .catch((error) => {
            console.warn(error)
          })
    }

    const createNewDate = (year, month, date, hh, mm) => {
      return new Date(year, month -1, date, hh, mm)
    }

    const compareStartedAtAndEndedAt = (startAt, endAt) => {
      if (startAt - endAt < 0) return endAt
      endAt.setDate(endAt.getDate() + 1)
      return endAt
    }

    const newStudyTimeRecord = () => {
      startedAt.value = createNewDate(store.state.calendarYear,store.state.calendarMonth, props.date, startedAtObject.value.HH, startedAtObject.value.mm )
      endedAt.value = createNewDate(store.state.calendarYear,store.state.calendarMonth, props.date, endedAtObject.value.HH, endedAtObject.value.mm)
      endedAt.value = compareStartedAtAndEndedAt(startedAt.value, endedAt.value)
      fetchDailyStudyTimeRecords()
    }

    return {
      startedAtObject,
      endedAtObject,
      errorStartedAtMessage,
      errorEndedAtMessage,
      isAbleCreateButton,
      newStudyTimeRecord,
    }
  }
}
</script>
