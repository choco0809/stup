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
  <table class="w-full">
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
          class="border border-black h-12">
          {{ date.date }}
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
export default {
  name: 'StudyCalendar',
  data() {
    return {
      currentYear: this.getCurrentYear(),
      currentMonth: this.getCurrentMonth(),
      calendarYear: this.getCurrentYear(),
      calendarMonth: this.getCurrentMonth()
    }
  },
  computed: {
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
        calendar.push({ date })
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
    this.loadState()
  },
  methods: {
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

      this.calendarYear = year
      this.calendarMonth = month
    },
    getCurrentYear() {
      return new Date().getFullYear()
    },
    getCurrentMonth() {
      return new Date().getMonth() + 1
    },
    previousMonth() {
      if (this.calendarMonth === 1) {
        this.calendarMonth = 12
        this.calendarYear = this.calendarYear - 1
      } else {
        this.calendarMonth = this.calendarMonth - 1
      }
      this.saveState()
    },
    nextMonth() {
      if (this.calendarMonth === 12) {
        this.calendarMonth = 1
        this.calendarYear = this.calendarYear + 1
      } else {
        this.calendarMonth = this.calendarMonth + 1
      }
      this.saveState()
    },
    newsMonth() {
      return (
        (this.calendarYear === this.currentYear) &
        (this.calendarMonth === this.currentMonth)
      )
    },
    saveState() {
      const year = String(this.calendarYear)
      const month = String(this.calendarMonth).padStart(2, '0')
      const params = new URLSearchParams(location.search)
      params.set('calendar', `${year}-${month}`)
      history.replaceState(history.state, '', `?${params}${location.hash}`)
    }
  }
}
</script>
