<template>
  <div class="text-center">
    <div class="flex justify-center p-2">
      <div class="text-center w-1/3">開始時間</div>
      <div class="w-2/3">
        <span class="border p-1">
          <select v-model="startedHours" class="bg-base-200 w-28 text-center">
            <option v-for="(text,value) in timeBox(24)" :value="value" :v-text="text">
              {{ text }}
            </option>
          </select>
          <span>：</span>
          <select v-model="startedMinutes" class="bg-base-200 w-28 text-center">
            <option v-for="(text,value) in timeBox(60)" :value="value" :v-text="text">
              {{ text }}
            </option>
          </select>
        </span>
      </div>
    </div>
    <div class="flex justify-center p-2">
      <div class="text-center w-1/3">終了時間</div>
      <div class="w-2/3">
        <span class="border p-1">
          <select v-model="endedHours" class="bg-base-200 w-28 text-center2">
            <option v-for="(text,value) in timeBox(24)" :value="value" :v-text="text">
              {{ text }}
            </option>
          </select>
          <span>：</span>
          <select v-model="endedMinutes" class="bg-base-200 w-28 text-center">
            <option v-for="(text,value) in timeBox(60)" :value="value" :v-text="text">
              {{ text }}
            </option>
          </select>
        </span>
      </div>
    </div>
    <div class="p-5">
      <button class="btn btn-info" @click="debug()">作成</button>
    </div>
  </div>
</template>

<script>

import {mapGetters} from 'vuex'

export default {
  name: "CreateStudyTimeRecord",
  data() {
    return {
      startedHours: '',
      startedMinutes: '',
      endedHours: '',
      endedMinutes: ''
    }
  },
  computed: {
    ...mapGetters(['calendarYear', 'calendarMonth'])
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    fetchDailyStudyTimeRecords() {
      fetch(
          `/api/study_time_records`,
          {
            method: 'POST',
            headers: {
              'X-Requested-With': 'XMLHttpRequest',
              'X-CSRF-Token': this.token()
            },
            credentials: 'same-origin'
          }
      )
          .then(() => {
            document.location.reload()
          })
          .catch((error) => {
            console.warn(error)
          })
    },
    timeBox(limitValue) {
      let options = {}
      for(let i =0; i < limitValue; i++) {
        options[i] = i.toString().padStart(2,'0')
      }
      return options
    },
    debug() {
      console.log(`開始時間：${this.startedHours}：${this.startedMinutes}`)
      console.log(`終了時間：${this.endedHours}：${this.endedMinutes}`)
    }
  }
}
</script>
