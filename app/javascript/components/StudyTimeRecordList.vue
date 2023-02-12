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
          <td
            class="modal-thread-list-contents border border-black text-center">
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
          <td
            class="modal-thread-list-contents border border-black text-left pl-2.5">
            {{ studyTimeRecords.memo }}
          </td>
          <td class="text-center">
            <button @click="fetchDailyStudyTimeRecords(studyTimeRecords)">
              <svg
                class="inline-block"
                type="button"
                width="36px"
                height="36px"
                viewBox="0 0 24 24"
                fill="none"
                xmlns="http://www.w3.org/2000/svg">
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g
                  id="SVGRepo_tracerCarrier"
                  stroke-linecap="round"
                  stroke-linejoin="round"></g>
                <g id="SVGRepo_iconCarrier">
                  <path
                    d="M6 7V18C6 19.1046 6.89543 20 8 20H16C17.1046 20 18 19.1046 18 18V7M6 7H5M6 7H8M18 7H19M18 7H16M10 11V16M14 11V16M8 7V5C8 3.89543 8.89543 3 10 3H14C15.1046 3 16 3.89543 16 5V7M8 7H16"
                    stroke="#000000"
                    stroke-width="2"
                    stroke-linecap="round"
                    stroke-linejoin="round"></path>
                </g>
              </svg>
            </button>
          </td>
          <td class="text-center">
            <button @click="openEditModal(studyTimeRecords)">
              <svg
                class="inline-block"
                type="button"
                fill="#000000"
                width="36px"
                height="36px"
                viewBox="0 0 32 32"
                version="1.1"
                xmlns="http://www.w3.org/2000/svg">
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g
                  id="SVGRepo_tracerCarrier"
                  stroke-linecap="round"
                  stroke-linejoin="round"></g>
                <g id="SVGRepo_iconCarrier">
                  <title>edit</title>
                  <path
                    d="M10.681 18.207l-2.209 5.67 5.572-2.307-3.363-3.363zM26.855 6.097l-0.707-0.707c-0.78-0.781-2.047-0.781-2.828 0l-1.414 1.414 3.535 3.536 1.414-1.414c0.782-0.781 0.782-2.048 0-2.829zM10.793 17.918l0.506-0.506 3.535 3.535 9.9-9.9-3.535-3.535 0.707-0.708-11.113 11.114zM23.004 26.004l-17.026 0.006 0.003-17.026 11.921-0.004 1.868-1.98h-14.805c-0.552 0-1 0.447-1 1v19c0 0.553 0.448 1 1 1h19c0.553 0 1-0.447 1-1v-14.058l-2.015 1.977 0.054 11.085z"></path>
                </g>
              </svg>
            </button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
  <div
    v-if="finishedStudyTime(dailyStudyTimeRecords, null)"
    class="text-center">
    <button class="btn btn-warning" @click="openCreateModal()">新規作成</button>
  </div>
</template>

<script>
import { computed } from 'vue'
import { useStore } from 'vuex'
import useStudyTimeRecordFunction from './functions/UseStudyTimeRecordFunction.vue'

export default {
  name: 'StudyTimeRecordList',
  setup() {
    const store = useStore()
    const { token, formatHours, formatMinutes } = useStudyTimeRecordFunction()

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
          store.commit('deleteStudyTimeRecord', { record: json })
          store.commit('closeShowModal')
        })
        .catch((error) => {
          console.warn(error)
        })
    }

    const openCreateModal = () => {
      store.commit('openCreateStudyRecordModal')
    }

    const openEditModal = (record) => {
      store.commit('updateEditStudyTimeRecord', {
        id: record.id,
        startedAt: record.started_at,
        endedAt: record.ended_at,
        memo: record.memo
      })
      store.commit('openEditStudyRecordModal')
    }

    const calculateStudyTime = (record) => {
      if (record.ended_at === null) {
        return null
      }
      const startedAt = new Date(record.started_at)
      const endedAt = new Date(record.ended_at)
      return Math.floor((endedAt - startedAt) / 1000 / 60)
    }

    return {
      dailyStudyTimeRecords: computed(
        () => store.getters.dailyStudyTimeRecords
      ),
      formatStartAndEndAt,
      finishedStudyTime,
      openCreateModal,
      openEditModal,
      calculateStudyTime,
      fetchDailyStudyTimeRecords
    }
  }
}
</script>
