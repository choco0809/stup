<template>
  <div
    class="z-10 fixed top-0 left-0 w-full h-full bg-black/70 flex items-center justify-center">
    <div class="bg-white rounded-lg z-20 w-2/4 pt-5 pb-5">
      <div>
        <div class="flex justify-center">
          <div class="text-center mb-3 basis-5/6 h-full text-lg font-bold">
            {{ calendarYear }} 年 {{ calendarMonth }} 月 {{ date }} 日の学習記録
          </div>
          <div class="text-center basis-1/6">
            <button @click="$emit('close')">
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
        </div>
        <div v-if="createModal" class="p-10">
          <div class="h-60 overflow-y-auto">
            <table class="w-full table-fixed">
              <thead>
                <tr class="bg-base-200">
                  <th class="border border-black">開始時間</th>
                  <th class="border border-black">終了時間</th>
                  <th class="border border-black">学習時間</th>
                  <th class="border border-black w-2/5">memo</th>
                </tr>
              </thead>
              <tbody
                v-for="studyTimeRecords in dailyStudyTimeRecords"
                :key="studyTimeRecords.id">
                <tr class="modal-thread-list-item">
                  <td
                    class="modal-thread-list-contents border border-black text-center">
                    {{ formatStartAndEndAt(studyTimeRecords.started_at) }}
                  </td>
                  <td
                    class="modal-thread-list-contents border border-black text-center">
                    {{ formatStartAndEndAt(studyTimeRecords.ended_at) }}
                  </td>
                  <td
                    v-if="calculateStudyTime(studyTimeRecords) !== null"
                    class="modal-thread-list-contents border border-black text-center">
                    {{ calculateStudyTime(studyTimeRecords) }}分
                  </td>
                  <td v-else class="border border-black text-center"></td>
                  <td class="modal-thread-list-contents border border-black text-left">
                    {{ studyTimeRecords.memo }}
                  </td>
                  <td class="text-center">
                    <button
                      class="btn btn-info"
                      @click="fetchDailyStudyTimeRecords(studyTimeRecords)">
                      削除
                    </button>
                  </td>
                  <td>
                    <button class="btn btn-warning">編集</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div
            v-if="finishedStudyTime(dailyStudyTimeRecords)"
            class="text-center">
            <button class="btn btn-warning" @click="openCreateModal()">
              新規作成
            </button>
          </div>
        </div>
        <div v-else>
          <CreateStudyTimeRecord :date="date"> </CreateStudyTimeRecord>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapMutations } from 'vuex'
import CreateStudyTimeRecord from './CreateStudyTimeRecord.vue'

export default {
  name: 'StudyTimeRecordsModal',
  components: {
    CreateStudyTimeRecord
  },
  props: {
    date: {
      type: Number,
      require: true,
      default: 0
    },
    dailyStudyTimeRecords: {
      type: Object,
      require: true,
      default: () => {}
    }
  },
  emits: ['close'],
  computed: {
    ...mapGetters([
      'calendarYear',
      'calendarMonth',
      'monthlyStudyTime',
      'createModal'
    ])
  },
  methods: {
    ...mapMutations([
      'openCreateStudyRecordModal',
      'deleteStudyTimeRecord',
      'closeShowModal'
    ]),
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    formatStartAndEndAt(timeStamp) {
      if (timeStamp === null) {
        return null
      }
      const targetDate = new Date(timeStamp)
      const hh = this.formatHours(targetDate.getHours())
      const mm = this.formatMinutes(targetDate.getMinutes())
      return `${hh}:${mm}`
    },
    formatHours(hours) {
      return hours.toString().padStart(2, '0')
    },
    formatMinutes(minutes) {
      return minutes.toString().padStart(2, '0')
    },
    calculateStudyTime(record) {
      if (record.ended_at === null) {
        return null
      }
      const startedAt = new Date(record.started_at)
      const endedAt = new Date(record.ended_at)
      return Math.floor((endedAt - startedAt) / 1000 / 60)
    },
    fetchDailyStudyTimeRecords(record) {
      fetch(`/api/study_time_records/${record.id}`, {
        method: 'DELETE',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.deleteStudyTimeRecord({ record: json })
          this.closeShowModal()
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    finishedStudyTime(record) {
      if (record.length === 0) return true
      for (const elem of record) {
        if (elem.ended_at === null) return false
      }
      return true
    },
    openCreateModal() {
      this.openCreateStudyRecordModal()
    }
  }
}
</script>
