<template>
  <div class="text-center">
    <div class="flex justify-center p-2">
      <div class="text-center w-1/3">開始時間</div>
      <div class="w-2/3">
        <span class="border p-1">
          <select v-model="startedHours" class="bg-base-200 w-28 text-center">
            <option v-for="(text,value) in timeBox(24)" :value="value" :v-text="text">
              {{ text }}
            </option>
          </select>
          <span>：</span>
          <select v-model="startedMinutes" class="bg-base-200 w-28 text-center">
            <option v-for="(text,value) in timeBox(60)" :value="value" :v-text="text">
              {{ text }}
            </option>
          </select>
        </span>
      </div>
    </div>
    <div class="flex justify-center p-2">
      <div class="text-center w-1/3">終了時間</div>
      <div class="w-2/3">
        <span class="border p-1">
          <select v-model="endedHours" class="bg-base-200 w-28 text-center">
            <option v-for="(text,value) in timeBox(24)" :value="value" :v-text="text">
              {{ text }}
            </option>
          </select>
          <span>：</span>
          <select v-model="endedMinutes" class="bg-base-200 w-28 text-center">
            <option v-for="(text,value) in timeBox(60)" :value="value" :v-text="text">
              {{ text }}
            </option>
          </select>
        </span>
      </div>
    </div>
    <div class="p-5">
      <button class="btn btn-info" @click="newStudyTimeRecord()">作成</button>
    </div>
  </div>
</template>

<script>

import {mapGetters, mapMutations} from 'vuex'

export default {
  name: "CreateStudyTimeRecord",
  data() {
    return {
      startedHours: '',
      startedMinutes: '',
      endedHours: '',
      endedMinutes: '',
    }
  },
  props: {
    date: {
      type: Number,
      require: true,
      default: ''
    }
  },
  computed: {
    ...mapGetters(['calendarYear', 'calendarMonth', 'monthlyStudyTime'])
  },
  methods: {
    ...mapMutations(['deleteStudyTimeRecord', 'addStudyTimeRecord','closeShowModal','closeCreateStudyRecordModal']),
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    fetchDailyStudyTimeRecords() {
      fetch(
          `/api/study_time_records`,
          {
            method: 'POST',
            body: JSON.stringify({
              started_at: this.startedAt,
              ended_at: this.endedAt
            }),
            headers: {
              'Content-Type': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
              'X-CSRF-Token': this.token()
            },
            credentials: 'same-origin'
          }
      )
          .then((response) => {
            return response.json()
          })
          .then((json) => {
            this.closeShowModal()
            this.closeCreateStudyRecordModal()
            this.addStudyTimeRecord({ studyTimeRecord: json })
          })
          .catch((error) => {
            console.warn(error)
          })
    },
    timeBox(limitValue) {
      let options = {}
      for(let i =0; i < limitValue; i++) {
        options[i] = i.toString().padStart(2,'0')
      }
      return options
    },
    newStudyTimeRecord() {
      const formatStartedHours = this.formatHours(this.startedHours)
      const formatStartedMinutes = this.formatMinutes(this.startedMinutes)
      const formatEndedHours = this.formatHours(this.endedHours)
      const formatEndedMinutes = this.formatMinutes(this.endedMinutes)
      this.startedAt = new Date(this.calendarYear, this.calendarMonth -1, this.date, formatStartedHours, formatStartedMinutes)
      this.endedAt = new Date(this.calendarYear, this.calendarMonth -1, this.date, formatEndedHours, formatEndedMinutes)
      this.fetchDailyStudyTimeRecords()
    },
    formatHours(hours) {
      return hours.toString().padStart(2, '0')
    },
    formatMinutes(minutes) {
      return minutes.toString().padStart(2, '0')
    }
  }
}
</script>
