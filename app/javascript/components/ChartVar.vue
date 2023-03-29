<template>
  <canvas id="myChart"></canvas>
</template>
<script>
import { Chart, LinearScale, CategoryScale, BarController, BarElement, UpdateMode } from 'chart.js'
import {watch, onMounted, shallowRef} from 'vue'
import {useStore} from 'vuex'
Chart.register(LinearScale, CategoryScale, BarController, BarElement)

export default {
  setup(){
    const store = useStore()
    let barChart = shallowRef()

    const renderChart = (labels) => {
      const canvas = document.getElementById("myChart")
      if (canvas === null) return
      const ctx = canvas.getContext("2d")
      barChart = shallowRef(new Chart(ctx, {
        type: 'bar',
        data: {
          labels: labels,
          datasets: [{
            label: '# of Votes',
            data: [10],
            borderWidth: 1
          }]
        },
        options: {
          scales: {
            y: {
              beginAtZero: true,
              grid: {
                display: false
              }
            },
            x: {
              ticks: {
                autoSkip: false,
                maxRotation: 0,
                minRotation: 0,
              },
              grid: {
                display: false
              }
            }
          }
        }
      }))
    }

    const createMonthlyCalendar = () => {
      const monthlyCalendar = []
      const year = store.getters.calendarYear
      const month = store.getters.calendarMonth
      const endOfMonth = new Date(year, month , 0).getDate()
      for(let i = 1; i <= 31; i++ ) {
        if (i <= endOfMonth) {
          monthlyCalendar.push(i)
        } else {
          monthlyCalendar.push(null)
        }

      }
      return monthlyCalendar
    }

    onMounted( () => {
      const label = createMonthlyCalendar()
      renderChart(label)
    } )

    const deleteLabelSets = () => {
      let bar = barChart.value
      const max = bar.data.labels.length
      for(let i=0; i < max; i++){
        bar.data.labels.pop()
      }
      bar.update()
    }

    watch( () => store.getters.calendarMonth, () => {
      let bar = barChart.value
      const label = createMonthlyCalendar()
      deleteLabelSets()
      label.forEach((elem) => {
        bar.data.labels.push(elem)
      })
      bar.update()
    }, {deep: true})

    return {
      barChart,
    }
  }
}

</script>
