import { createApp } from 'vue'
import App from './chart.vue'
import store from './store'

document.addEventListener('DOMContentLoaded', () => {
  createApp(App).use(store).mount('#chart')
})
