<template>
  <div class="flex justify-center">
    <div class="w-4" @click="previousMonth">
      <button class="hover:border-b-2 border-black">＜</button>
    </div>
    <div class="text-center mb-3 w-48">
      {{ calendarYear }} 年 {{ calendarMonth }} 月
    </div>
    <div v-if="!newsMonth()" class="w-4" @click="nextMonth">
      <button class="hover:border-b-2 border-black">＞</button>
    </div>
    <div v-else class="w-4"></div>
  </div>
  <table class="w-full table-fixed">
    <thead>
      <tr class="bg-base-200">
        <th class="border border-black w-1/7">日</th>
        <th class="border border-black w-1/7">月</th>
        <th class="border border-black w-1/7">火</th>
        <th class="border border-black w-1/7">水</th>
        <th class="border border-black w-1/7">木</th>
        <th class="border border-black w-1/7">金</th>
        <th class="border border-black w-1/7">土</th>
      </tr>
    </thead>
    <tbody v-for="week in calendarWeeks" :key="week.id">
      <tr class="text-center">
        <td
          v-for="date in week.value"
          :key="date.weekDay"
          class="border border-black h-16">
          <div v-if="date.date" class="study-ask">
            <div>
              {{ date.date }}
            </div>
            <div class="study-time">
              <div v-if="futureDate(date.date)">▲</div>
              <div v-else-if="studyTimesLength(date.dailyStudyTime)">
                <button @click="openModal(date)">ー</button>
              </div>
              <div v-else>
                <button @click="openModal(date)">
                  {{ totalStudyTimes(date.dailyStudyTime) }}分
                </button>
              </div>
            </div>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
  <StudyTimeRecordsModal
    v-show="showModal"
    :date="modalDate"
    :daily-study-time-records="modalItems"
    @close="closeModal"></StudyTimeRecordsModal>
</template>

<script>
import { mapActions, mapGetters, mapMutations } from 'vuex'
import StudyTimeRecordsModal from './components/StudyTimeRecordsModal.vue'

export default {
  name: 'StudyCalendar',
  components: { StudyTimeRecordsModal },
  data() {
    return {
      modalDate: '',
      modalItems: []
    }
  },
  computed: {
    ...mapGetters([
      'calendarYear',
      'calendarMonth',
      'monthlyStudyTime',
      'showModal'
    ]),
    calendarWeeks() {
      const weekArry = []
      let value = []
      let id = 1
      let weekDay = 0
      this.calendarDates.forEach(function (date, i, ary) {
        !date ? (date = { weekDay }) : (date.weekDay = weekDay)
        value.push(date)
        weekDay++
        if (value.length === 7 || i === ary.length - 1) {
          weekArry.push({ id, value })
          id++
          value = []
          weekDay = 0
        }
      })
      this.$store.commit('updateCalendar', { calendar: weekArry })
      return weekArry
    },
    calendarDates() {
      const calendar = []
      if (this.firstWday > 0) {
        for (let blank = 0; blank < this.firstWday; blank++) {
          calendar.push(null)
        }
      }
      for (let date = 1; date <= this.lastDate; date++) {
        const dailyStudyTime = this.monthlyStudyTime.filter(
          (studyTimeRecord) => {
            return studyTimeRecord.started_at.includes(
              `${this.calendarYear}-${this.formatMonth(
                this.calendarMonth
              )}-${this.formatDay(date)}`
            )
          }
        )
        calendar.push({ date, dailyStudyTime })
      }
      return calendar
    },
    firstWday() {
      const firstDay = new Date(this.calendarYear, this.calendarMonth - 1, 1)
      return firstDay.getDay()
    },
    lastDate() {
      const lastDay = new Date(this.calendarYear, this.calendarMonth, 0)
      return lastDay.getDate()
    }
  },
  mounted() {
    this.setCurrentYearAndCalendarYear()
    this.setCurrentMonthAndCalendarMonth()
    this.loadState()
    this.fetchMonthlyStudyTimeRecords()
  },
  methods: {
    ...mapMutations([
      'updateCalendarYear',
      'updateCalendarMonth',
      'updateMonthlyStudyTime',
      'openShowModal',
      'closeShowModal',
      'closeCreateStudyRecordModal'
    ]),
    ...mapActions([
      'setCurrentYearAndCalendarYear',
      'setCurrentMonthAndCalendarMonth'
    ]),
    loadState() {
      const params = new URLSearchParams(location.search)
      const yearMonth = params.get('calendar') || ''
      const match = /(\d{4})-(\d{2})/.exec(yearMonth)
      if (!match) {
        return
      }
      const year = parseInt(match[1])
      const month = parseInt(match[2])
      if (new Date(year, month).getTime() > Date.now()) {
        return
      }

      this.updateCalendarYear({ year })
      this.updateCalendarMonth({ month })
    },
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    previousMonth() {
      if (this.calendarMonth === 1) {
        this.updateCalendarMonth({ month: 12 })
        this.updateCalendarYear({ year: this.calendarYear - 1 })
      } else {
        this.updateCalendarMonth({ month: this.calendarMonth - 1 })
      }
      this.saveState()
      this.fetchMonthlyStudyTimeRecords()
    },
    nextMonth() {
      if (this.calendarMonth === 12) {
        this.updateCalendarMonth({ month: 1 })
        this.updateCalendarYear({ year: this.calendarYear + 1 })
      } else {
        this.updateCalendarMonth({ month: this.calendarMonth + 1 })
      }
      this.saveState()
      this.fetchMonthlyStudyTimeRecords()
    },
    newsMonth() {
      return (
        (this.calendarYear === this.$store.state.currentYear) &
        (this.calendarMonth === this.$store.state.currentMonth)
      )
    },
    saveState() {
      const year = String(this.calendarYear)
      const month = String(this.calendarMonth).padStart(2, '0')
      const params = new URLSearchParams(location.search)
      params.set('calendar', `${year}-${month}`)
      history.replaceState(history.state, '', `?${params}${location.hash}`)
    },
    fetchMonthlyStudyTimeRecords() {
      fetch(
        `/api/study_time_records?year=${this.calendarYear}&month=${this.calendarMonth}`,
        {
          method: 'GET',
          headers: {
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
          this.updateMonthlyStudyTime({ monthlyStudyTime: json })
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    formatDay(day) {
      return day.toString().padStart(2, '0')
    },
    formatMonth(month) {
      return month.toString().padStart(2, '0')
    },
    studyTimesLength(studyTimes) {
      return studyTimes.length === 0
    },
    totalStudyTimes(studyTimes) {
      return studyTimes.reduce(function (sum, records) {
        if (records.ended_at == null) {
          return sum + 0
        } else {
          const startedAt = new Date(records.started_at)
          const endedAt = new Date(records.ended_at)
          const studyTime = Math.floor((endedAt - startedAt) / 1000 / 60)
          return sum + studyTime
        }
      }, 0)
    },
    futureDate(date) {
      const nowDate = this.getFormattedNowDate()
      const targetDate =
        this.calendarYear +
        this.formatMonth(this.calendarMonth) +
        this.formatDay(date)
      return targetDate > nowDate
    },
    getFormattedNowDate() {
      const nowDate = new Date()
      const year = nowDate.getFullYear()
      const month = this.formatMonth(nowDate.getMonth() + 1)
      const day = this.formatDay(nowDate.getDate())
      return year + month + day
    },
    openModal(date) {
      this.modalDate = date.date
      this.modalItems = date.dailyStudyTime
      this.openShowModal()
    },
    closeModal() {
      this.closeShowModal()
      this.closeCreateStudyRecordModal()
    }
  }
}
</script>
