<template>
  <div class="h-60 overflow-y-auto">
    <table class="w-full table-fixed">
      <thead>
      <tr class="bg-base-200">
        <th class="border border-black">開始時間</th>
        <th class="border border-black">終了時間</th>
        <th class="border border-black">学習時間</th>
        <th class="border border-black w-2/5">memo</th>
      </tr>
      </thead>
      <tbody
          v-for="studyTimeRecords in dailyStudyTimeRecords"
          :key="studyTimeRecords.id">
      <tr class="modal-thread-list-item">
        <td class="modal-thread-list-contents border border-black text-center">
          {{ formatStartAndEndAt(studyTimeRecords.started_at, null) }}
        </td>
        <td
            class="modal-thread-list-contents border border-black text-center">
          {{ formatStartAndEndAt(studyTimeRecords.ended_at, null) }}
        </td>
        <td
            v-if="calculateStudyTime(studyTimeRecords, null) !== null"
            class="modal-thread-list-contents border border-black text-center">
          {{ calculateStudyTime(studyTimeRecords, null) }}分
        </td>
        <td v-else class="border border-black text-center"></td>
        <td class="modal-thread-list-contents border border-black text-left">
          {{ studyTimeRecords.memo }}
        </td>
        <td class="text-center">
          <button
              class="btn btn-info"
              @click="fetchDailyStudyTimeRecords(studyTimeRecords)">
            削除
          </button>
        </td>
        <td>
          <button class="btn btn-warning">編集</button>
        </td>
      </tr>
      </tbody>
    </table>
  </div>
  <div
    v-if="finishedStudyTime(dailyStudyTimeRecords, null)"
    class="text-center">
    <button class="btn btn-warning" @click="openCreateModal()">
      新規作成
    </button>
  </div>
</template>

<script>
import {computed} from 'vue'
import {useStore} from 'vuex'

export default {
  name: "StudyTimeRecordList",
  setup() {
    const store = useStore()

    const formatHours = (hours) => {
      return hours.toString().padStart(2, '0')
    }

    const formatMinutes = (minutes) => {
      return minutes.toString().padStart(2, '0')
    }

    const formatStartAndEndAt = (timeStamp) => {
      if (timeStamp === null) return null
      const targetDate = new Date(timeStamp)
      const hh = formatHours(targetDate.getHours())
      const mm = formatMinutes(targetDate.getMinutes())
      return `${hh}:${mm}`
    }

    const finishedStudyTime = (record) => {
      if (record.length === 0) return true
      for (const elem of record) {
        if (elem.ended_at === null) return false
      }
      return true
    }

    const openCreateModal = () => {
      store.commit('openCreateStudyRecordModal')
    }

    const calculateStudyTime = (record) => {
      if (record.ended_at === null) {
        return null
      }
      const startedAt = new Date(record.started_at)
      const endedAt = new Date(record.ended_at)
      return Math.floor((endedAt - startedAt) / 1000 / 60)
    }

    const token = () => {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    }

    const fetchDailyStudyTimeRecords = (record) => {
      fetch(`/api/study_time_records/${record.id}`, {
        method: 'DELETE',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': token()
        },
        credentials: 'same-origin'
      })
          .then((response) => {
            return response.json()
          })
          .then((json) => {
            store.commit('deleteStudyTimeRecord', {record: json})
            store.commit('closeShowModal')
          })
          .catch((error) => {
            console.warn(error)
          })
    }

    return {
      dailyStudyTimeRecords: computed(()=> store.getters.dailyStudyTimeRecords),
      formatStartAndEndAt,
      finishedStudyTime,
      openCreateModal,
      calculateStudyTime,
      fetchDailyStudyTimeRecords,
    }
  }
}
</script>
