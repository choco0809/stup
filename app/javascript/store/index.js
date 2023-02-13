import { createStore } from 'vuex'

export default createStore({
  state: {
    currentYear: '',
    currentMonth: '',
    calendarYear: '',
    calendarMonth: '',
    calendar: [],
    monthlyStudyTime: [],
    dailyStudyTimeRecords: [],
    editStudyTimeRecord: { id: null, startedAt: null, endedAt: null, memo: null },
    showModal: false,
    createModal: false,
    editModal: false
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
      state.calendar = payload.calendar
    },
    updateMonthlyStudyTime(state, payload) {
      state.monthlyStudyTime = payload.monthlyStudyTime
    },
    updateDailyStudyTimeRecords(state, payload) {
      state.dailyStudyTimeRecords = payload.dailyStudyTimeRecords
    },
    deleteStudyTimeRecord(state, payload) {
      const result = state.monthlyStudyTime.filter(function (item) {
        return item.id !== payload.record.id
      })
      state.monthlyStudyTime = result
    },
    addStudyTimeRecord(state, payload) {
      state.monthlyStudyTime.push(payload.studyTimeRecord)
    },
    openShowModal(state) {
      state.showModal = true
    },
    closeShowModal(state) {
      state.showModal = false
    },
    openCreateStudyRecordModal(state) {
      state.createModal = true
    },
    closeCreateStudyRecordModal(state) {
      state.createModal = false
    },
    openEditStudyRecordModal(state) {
      state.editModal = true
    },
    closeEditStudyRecordModal(state) {
      state.editModal = false
    },
    updateEditStudyTimeRecord(state, payload) {
      state.editStudyTimeRecord = payload
    }
  },
  getters: {
    calendarYear(state) {
      return state.calendarYear
    },
    calendarMonth(state) {
      return state.calendarMonth
    },
    monthlyStudyTime(state) {
      return state.monthlyStudyTime
    },
    showModal(state) {
      return state.showModal
    },
    createModal(state) {
      return state.createModal
    },
    editModal(state) {
      return state.editModal
    },
    dailyStudyTimeRecords(state) {
      return state.dailyStudyTimeRecords
    },
    editStudyTimeRecord(state) {
      return state.editStudyTimeRecord
    }
  },
  actions: {
    setCurrentYearAndCalendarYear({ commit }) {
      commit('updateCurrentYear')
      commit('updateCalendarYear', { year: this.state.currentYear })
    },
    setCurrentMonthAndCalendarMonth({ commit }) {
      commit('updateCurrentMonth')
      commit('updateCalendarMonth', { month: this.state.currentMonth })
    }
  }
})
