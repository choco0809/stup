<template>
  <div class="text-center">
    <div class="flex justify-center p-2">
      <div class="text-center w-1/3">開始時間</div>
      <div class="w-2/3">
        <VueTimepicker
            v-model="this.startedObjectTime"
            input-class="form-control"
            manual-input hide-dropdown
        />
      </div>
    </div>
    <div class="flex justify-center p-2">
      <div class="text-center w-1/3">終了時間</div>
      <div class="w-2/3">
        <VueTimepicker
            v-model="this.endedObjectTime"
            input-class="form-control"
            manual-input hide-dropdown
        />
      </div>
    </div>
    <div class="p-5">
      <button class="btn btn-info" @click="newStudyTimeRecord()">作成</button>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapMutations } from 'vuex'
import VueTimepicker from 'vue3-timepicker/src/VueTimepicker.vue'

export default {
  name: 'CreateStudyTimeRecord',
  props: {
    date: {
      type: Number,
      require: true,
      default: 0
    }
  },
  data() {
    return {
      startedAt: '',
      endedAt: '',
      startedObjectTime: {
        HH: '00',
        mm: '00'
      },
      endedObjectTime: {
        HH: '00',
        mm: '00'
      }
    }
  },
  components:{
    VueTimepicker
  },
  computed: {
    ...mapGetters(['calendarYear', 'calendarMonth', 'monthlyStudyTime'])
  },
  methods: {
    ...mapMutations([
      'deleteStudyTimeRecord',
      'addStudyTimeRecord',
      'closeShowModal',
      'closeCreateStudyRecordModal'
    ]),
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    fetchDailyStudyTimeRecords() {
      fetch(`/api/study_time_records`, {
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
      })
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
    newStudyTimeRecord() {
      this.startedAt = new Date(
        this.calendarYear,
        this.calendarMonth - 1,
        this.date,
        this.startedObjectTime.HH,
        this.startedObjectTime.mm
      )
      this.endedAt = new Date(
        this.calendarYear,
        this.calendarMonth - 1,
        this.date,
        this.endedObjectTime.HH,
        this.endedObjectTime.mm,
      )
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
