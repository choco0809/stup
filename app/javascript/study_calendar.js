import { createApp } from 'vue'
import App from './study_calendar.vue'
import store from './store'

document.addEventListener('DOMContentLoaded', () => {
  createApp(App).use(store).mount('#study_calendar')
})
