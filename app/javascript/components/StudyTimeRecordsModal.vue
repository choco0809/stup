<template>
  <div
    class="fixed bg-black bg-opacity-5 z-10 top-0 left-0 w-full h-full flex items-center justify-center">
    <div class="bg-white rounded-lg z-20 w-2/4 pt-5 pb-20">
      <div class="text-right mx-10">
        <button class="btn btn-circle" @click="$emit('close')">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-6 w-6"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
      <div>
        <div class="flex justify-center">
          <div class="text-center mb-3">
            {{ calendarYear }} 年 {{ calendarMonth }} 月 {{ date }} 日の学習記録
          </div>
        </div>
        <table class="w-3/4 table-fixed">
          <thead>
            <tr class="bg-base-200">
              <th class="border border-black 1/3">開始時間</th>
              <th class="border border-black 1/3">終了時間</th>
              <th class="border border-black 1/3">学習時間</th>
            </tr>
          </thead>
          <tbody v-for="studyTimeRecords in dailyStudyTimeRecords" :key="studyTimeRecords.id">
            <tr>
              <td class="border border-black 1/3">
                {{ formatStartAndEndAt(studyTimeRecords.started_at) }}
              </td>
              <td class="border border-black 1/3">
                {{ formatStartAndEndAt(studyTimeRecords.ended_at) }}
              </td>
              <td class="border border-black 1/3">
                {{ calculateStudyTime(studyTimeRecords) }} 分
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'StudyTimeRecordsModal',
  // props: ['date', `dailyStudyTimeRecords`],
  props: {
    date: String,
    dailyStudyTimeRecords: Object
  },
  emits:['close'],
  computed: {
    ...mapGetters(['calendarYear', 'calendarMonth', 'monthlyStudyTime'])
  },
  methods: {
    formatStartAndEndAt(timeStamp) {
      const targetDate = new Date(timeStamp)
      const hh = this.formatHours(targetDate.getHours())
      const mm = this.formatMinutes(targetDate.getMinutes())
      const ss = this.formatSeconds(targetDate.getSeconds())
      return `${hh}:${mm}:${ss}`
    },
    formatHours(hours) {
      return hours.toString().padStart(2, '0')
    },
    formatMinutes(minutes) {
      return minutes.toString().padStart(2, '0')
    },
    formatSeconds(seconds) {
      return seconds.toString().padStart(2, '0')
    },
    calculateStudyTime(record) {
      const startedAt = new Date(record.started_at)
      const endedAt = new Date(record.ended_at)
      return Math.floor((endedAt - startedAt) / 1000 / 60)
    }
  }
}
</script>
