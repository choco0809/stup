<template>
  <table class="w-full">
    <thead>
      <tr class="bg-base-200">
        <th class = "border border-black w-1/7">日</th>
        <th class = "border border-black w-1/7">月</th>
        <th class = "border border-black w-1/7">火</th>
        <th class = "border border-black w-1/7">水</th>
        <th class = "border border-black w-1/7">木</th>
        <th class = "border border-black w-1/7">金</th>
        <th class = "border border-black w-1/7">土</th>
      </tr>
    </thead>
    <tbody v-for="week in calendarWeeks" :key="week.id">
      <tr class="text-center">
        <td v-for="date in week.value" :key="date.weekDay" class="border border-black h-12">
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
        !date ? (date = { weekDay: weekDay }) : (date.weekDay = weekDay)
        value.push(date)
        weekDay++
        // 7日事に配列をまとめてpushする
        if (value.length === 7 || i === ary.length - 1) {
          weekArry.push({ id: id, value: value })
          id++
          value = []
          weekDay = 0
        }
      })
      return weekArry
    },
    calendarDates(){
      const calendar = []
      if (this.firstWday > 0) {
        for (let blank = 0; blank < this.firstWday; blank++) {
          calendar.push(null)
        }
        for (let date = 1; date <= this.lastDate; date++) {
          calendar.push({ date: date })
        }
      }
      return calendar
    },
    firstWday(){
      const firstDay = new Date(this.calendarYear, this.calendarMonth - 1, 1)
      return firstDay.getDay()
    },
    lastDate() {
      const lastDay = new Date(this.calendarYear, this.calendarMonth, 0)
      return lastDay.getDate()
    },
  },
  methods: {
    getCurrentYear() {
      return new Date().getFullYear()
    },
    getCurrentMonth() {
      return new Date().getMonth() + 1
    }
  }
}
</script>
