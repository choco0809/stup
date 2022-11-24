import { createStore } from 'vuex'

export default createStore({
  state: {
    currentYear: '',
    currentMonth: '',
    calendarYear: '',
    calendarMonth: '',
    calendar:[]
  },
  mutations: {
    updateCurrentYear(state) {
      state.currentYear = new Date().getFullYear()
    },
    updateCurrentMonth(state) {
      state.currentMonth = new Date().getMonth() + 1
    },
    updateCalendarYear(state, payload) {
      state.calendarYear = payload.year
    },
    updateCalendarMonth(state, payload) {
      state.calendarMonth = payload.month
    },
    updateCalendar(state, payload) {
      console.log("mutations$updateCalendar")
      state.calendar = payload.calendar
    }
  },
  getters: {
    calendarYear(state) {
      return state.calendarYear
    },
    calendarMonth(state) {
      return state.calendarMonth
    }
  },
  actions: {
    setCurrentYearAndCalendarYear({ commit }) {
      commit("updateCurrentYear")
      commit("updateCalendarYear", { year: this.state.currentYear })
    },
    setCurrentMonthAndCalendarMonth({ commit }) {
      commit("updateCurrentMonth")
      commit("updateCalendarMonth", { month: this.state.currentMonth })
    }
  }
})
