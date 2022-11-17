import { createApp } from 'vue'
import App from './calendar.vue'

document.addEventListener("DOMContentLoaded", () => {
  const calendar = document.getElementById("calendar")
  createApp(App).mount("#calendar")
});
