<template>
  <canvas id="myChart"></canvas>
</template>
<script>
import {
  Chart,
  LinearScale,
  CategoryScale,
  BarController,
  BarElement
} from 'chart.js'
import { watch, onMounted, shallowRef } from 'vue'
import { useStore } from 'vuex'
import useStudyTimeRecordFunction from './functions/UseStudyTimeRecordFunction.vue'
Chart.register(LinearScale, CategoryScale, BarController, BarElement)

export default {
  setup() {
    const store = useStore()
    const { formatDay } = useStudyTimeRecordFunction()
    let barChart = shallowRef()

    const renderChart = (labels) => {
      const canvas = document.getElementById('myChart')
      if (canvas === null) return
      const ctx = canvas.getContext('2d')
      barChart = shallowRef(
        new Chart(ctx, {
          type: 'bar',
          data: {
            labels,
            datasets: [
              {
                label: '# of Votes',
                data: [],
                borderWidth: 1
              }
            ]
          },
          options: {
            scales: {
              y: {
                beginAtZero: true,
                suggestedMax: 60,
                ticks: {
                  stepSize: 10
                },
                grid: {
                  display: false
                }
              },
              x: {
                ticks: {
                  autoSkip: false,
                  maxRotation: 0,
                  minRotation: 0
                },
                grid: {
                  display: false
                }
              }
            }
          }
        })
      )
    }

    const createMonthlyCalendar = () => {
      const monthlyCalendar = []
      const year = store.getters.calendarYear
      const month = store.getters.calendarMonth
      const endOfMonth = new Date(year, month, 0).getDate()
      for (let i = 1; i <= 31; i++) {
        if (i <= endOfMonth) {
          monthlyCalendar.push(i)
        } else {
          monthlyCalendar.push(null)
        }
      }
      return monthlyCalendar
    }

    onMounted(() => {
      const label = createMonthlyCalendar()
      renderChart(label)
    })

    const createDataSets = () => {
      const monthlyCalendar = createMonthlyCalendar()
      const monthlyStudyTime = store.getters.monthlyStudyTime
      const dataSets = monthlyCalendar.map((index) => {
        const totalDailyStudyTime = monthlyStudyTime.filter((record) => {
          if (index !== null) {
            return record.started_at.substring(8, 10).includes(formatDay(index))
          }
        })
        if (totalDailyStudyTime.length) {
          return totalDailyStudyTime.reduce(function (sum, records) {
            if (records.ended_at == null) {
              return sum + 0
            } else {
              const startedAt = new Date(records.started_at)
              const endedAt = new Date(records.ended_at)
              const studyTime = Math.floor((endedAt - startedAt) / 1000 / 60)
              return sum + studyTime
            }
          }, 0)
        } else {
          return 0
        }
      })
      return dataSets
    }

    watch(
      () => store.getters.monthlyStudyTime,
      () => {
        const chart = barChart.value
        const label = createMonthlyCalendar()
        const dataSets = createDataSets()
        chart.data.labels = label
        chart.data.datasets[0].data = dataSets
        chart.update('none')
      },
      { deep: true }
    )

    return {
      barChart
    }
  }
}
</script>
