<template>
  <div
    class="z-10 fixed top-0 left-0 w-full h-full bg-black/70 flex items-center justify-center">
    <div class="bg-white rounded-lg z-20 w-2/4 pt-5 pb-5">
      <div class="flex justify-center">
        <div class="text-center mb-3 basis-5/6 h-full text-lg font-bold">
          {{ calendarYear }} 年 {{ calendarMonth }} 月 {{ date }} 日の学習記録
        </div>
        <div class="text-center basis-1/6">
          <button @click="closeEmit">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
      <div v-if="!createModal && !editModal" class="p-10">
        <StudyTimeRecordList :date="date" />
      </div>
      <div v-else-if="createModal">
        <CreateStudyTimeRecord :date="date"> </CreateStudyTimeRecord>
      </div>
      <div v-else>
        <EditStudyTimeRecord :date="date"></EditStudyTimeRecord>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'
import { useStore } from 'vuex'
import CreateStudyTimeRecord from './CreateStudyTimeRecord.vue'
import StudyTimeRecordList from './StudyTimeRecordList.vue'
import EditStudyTimeRecord from './EditStudyTimeRecord.vue'

export default {
  name: 'StudyTimeRecordModal',
  components: {
    CreateStudyTimeRecord,
    StudyTimeRecordList,
    EditStudyTimeRecord
  },
  props: {
    date: {
      type: Number,
      require: true,
      default: 0
    }
  },
  emits: ['close'],
  setup(props, { emit }) {
    const closeEmit = () => {
      emit('close')
    }
    const store = useStore()

    return {
      calendarYear: computed(() => store.getters.calendarYear),
      calendarMonth: computed(() => store.getters.calendarMonth),
      createModal: computed(() => store.getters.createModal),
      editModal: computed(() => store.getters.editModal),
      closeEmit
    }
  }
}
</script>
