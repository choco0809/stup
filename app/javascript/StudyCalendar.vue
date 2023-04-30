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
          :class="date.highlight ? 'border border-black h-16 shadow-highlight' : 'border border-black h-16'">
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
  <StudyTimeRecordModal
    v-show="showModal"
    :date="modalDate"
    @close="closeModal"></StudyTimeRecordModal>
</template>

<script>
import StudyTimeRecordModal from './components/StudyTimeRecordModal.vue'
import { onMounted, computed, ref } from 'vue'
import { useStore } from 'vuex'
import useStudyTimeRecordFunction from './components/functions/UseStudyTimeRecordFunction.vue'

export default {
  name: 'StudyCalendar',
  components: {
    StudyTimeRecordModal
  },
  setup() {
    const store = useStore()
    const { formatDay, formatMonth, token } = useStudyTimeRecordFunction()
    const modalDate = ref(0)

    const firstWday = computed(() => {
      const firstDay = new Date(
        store.getters.calendarYear,
        store.getters.calendarMonth - 1,
        1
      )
      return firstDay.getDay()
    })

    const lastDate = computed(() => {
      const lastDay = new Date(
        store.getters.calendarYear,
        store.getters.calendarMonth,
        0
      )
      return lastDay.getDate()
    })

    const isEndedAtSet = (array) => {
      if(array.length === 0) return false
      return array.some(item => item.ended_at === null)
    }

    const calendarDates = computed(() => {
      const calendar = []
      if (firstWday.value > 0) {
        for (let blank = 0; blank < firstWday.value; blank++) {
          calendar.push(null)
        }
      }
      for (let date = 1; date <= lastDate.value; date++) {
        const dailyStudyTime = store.getters.monthlyStudyTime.filter(
          (studyTimeRecord) => {
            return studyTimeRecord.started_at.includes(
              `${store.getters.calendarYear}-${formatMonth(
                store.getters.calendarMonth
              )}-${formatDay(date)}`
            )
          }
        )
        calendar.push({ date, dailyStudyTime, highlight: isEndedAtSet(dailyStudyTime) })
      }
      return calendar
    })

    const calendarWeeks = computed(() => {
      const weekArry = []
      let value = []
      let id = 1
      let weekDay = 0
      calendarDates.value.forEach(function (date, i, ary) {
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
      store.commit('updateCalendar', { calendar: weekArry })
      return weekArry
    })

    const loadState = () => {
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
      store.commit('updateCalendarYear', { year })
      store.commit('updateCalendarMonth', { month })
    }

    const fetchMonthlyStudyTimeRecords = () => {
      fetch(
        `/api/study_time_records?year=${store.getters.calendarYear}&month=${store.getters.calendarMonth}`,
        {
          method: 'GET',
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': token()
          },
          credentials: 'same-origin'
        }
      )
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          store.commit('updateMonthlyStudyTime', { monthlyStudyTime: json })
        })
        .catch((error) => {
          console.warn(error)
        })
    }

    const saveState = () => {
      const year = String(store.getters.calendarYear)
      const month = String(store.getters.calendarMonth).padStart(2, '0')
      const params = new URLSearchParams(location.search)
      params.set('calendar', `${year}-${month}`)
      history.replaceState(history.state, '', `?${params}${location.hash}`)
    }

    const previousMonth = () => {
      if (store.getters.calendarMonth === 1) {
        store.commit('updateCalendarMonth', { month: 12 })
        store.commit('updateCalendarYear', {
          year: store.getters.calendarYear - 1
        })
      } else {
        store.commit('updateCalendarMonth', {
          month: store.getters.calendarMonth - 1
        })
      }
      saveState()
      fetchMonthlyStudyTimeRecords()
    }

    const nextMonth = () => {
      if (store.getters.calendarMonth === 12) {
        store.commit('updateCalendarMonth', { month: 1 })
        store.commit('updateCalendarYear', {
          year: store.getters.calendarYear + 1
        })
      } else {
        store.commit('updateCalendarMonth', {
          month: store.getters.calendarMonth + 1
        })
      }
      saveState()
      fetchMonthlyStudyTimeRecords()
    }

    const newsMonth = () => {
      return (
        (store.getters.calendarYear === store.getters.currentYear) &
        (store.getters.calendarMonth === store.getters.currentMonth)
      )
    }

    const getFormattedNowDate = () => {
      const nowDate = new Date()
      const year = nowDate.getFullYear()
      const month = formatMonth(nowDate.getMonth() + 1)
      const day = formatDay(nowDate.getDate())
      return year + month + day
    }

    const futureDate = (date) => {
      const nowDate = getFormattedNowDate()
      const targetDate =
        store.getters.calendarYear +
        formatMonth(store.getters.calendarMonth) +
        formatDay(date)
      return targetDate > nowDate
    }

    const studyTimesLength = (studyTimes) => {
      return studyTimes.length === 0
    }

    const totalStudyTimes = (studyTimes) => {
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
    }

    const openModal = (date) => {
      modalDate.value = Number(date.date)
      store.commit('updateDailyStudyTimeRecords', {
        dailyStudyTimeRecords: date.dailyStudyTime
      })
      store.commit('openShowModal')
    }

    const closeModal = () => {
      store.commit('closeShowModal')
      store.commit('closeCreateStudyRecordModal')
      store.commit('closeEditStudyRecordModal')
    }

    onMounted(() => {
      store.dispatch('setCurrentYearAndCalendarYear')
      store.dispatch('setCurrentMonthAndCalendarMonth')
      loadState()
      fetchMonthlyStudyTimeRecords()
    })

    return {
      modalDate,
      calendarYear: computed(() => store.getters.calendarYear),
      calendarMonth: computed(() => store.getters.calendarMonth),
      showModal: computed(() => store.getters.showModal),
      calendarWeeks,
      previousMonth,
      nextMonth,
      newsMonth,
      futureDate,
      studyTimesLength,
      totalStudyTimes,
      openModal,
      closeModal
    }
  }
}
</script>
