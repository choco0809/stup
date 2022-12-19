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
              <div v-if="this.futureDate(date.date)"> ▲ </div>
              <div v-else-if="studyTimesLength(date.dailyStudyTime)"> ー </div>
              <div v-else>
                {{ totalStudyTimes(date.dailyStudyTime) }}分
              </div>
            </div>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import { mapGetters, mapMutations, mapActions } from 'vuex'

export default {
  name: 'StudyCalendar',
  computed: {
    ...mapGetters(['calendarYear', 'calendarMonth', 'monthlyStudyTime']),
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
        const dailyStudyTime = this.monthlyStudyTime.filter((studyTimeRecord) => {
          return studyTimeRecord.started_at.includes(
              `${this.calendarYear}-${this.calendarMonth}-${this.formatDay(date)}`
          )
        })
        calendar.push({ date, dailyStudyTime: dailyStudyTime })
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
    ...mapMutations(['updateCalendarYear', 'updateCalendarMonth', 'updateMonthlyStudyTime']),
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
      fetch(`/api/study_time_records?year=${this.calendarYear}&month=${this.calendarMonth}`, {
        method: 'GET',
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
            this.updateMonthlyStudyTime( {monthlyStudyTime: json})
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
      return (studyTimes.length === 0 ? true : false)
    },
    totalStudyTimes(studyTimes) {
        const totalStudyTime = studyTimes.reduce(function (sum, records){
          const started_at = new Date(records.started_at)
          const ended_at = new Date(records.ended_at)
          const study_time = Math.floor((ended_at - started_at) / 1000 / 60)
          return sum + study_time
      },0)

      return totalStudyTime
    },
    futureDate(date) {
      const nowDate = this.getFormattedNowDate()
      const targetDate = this.calendarYear + this.formatMonth(this.calendarMonth) + this.formatDay(date)
      return targetDate > nowDate
    },
    getFormattedNowDate() {
      const nowDate = new Date()
      const year = nowDate.getFullYear()
      const month = this.formatMonth(nowDate.getMonth() + 1)
      const day = this.formatDay(nowDate.getDate())
      return (year + month + day)
    }
  }
}
</script>
