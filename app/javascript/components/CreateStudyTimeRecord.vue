<template>
  <div class="text-center">
    <div class="flex justify-center p-2">
      <div class="text-center w-1/3">開始時間</div>
      <div class="w-2/3">
        <VueTimepicker
          id="startAt"
          v-model="startedAtObject"
          class="float-left"
          name="startAt"
          input-class="form-control"
          manual-input
          hide-dropdown />
      </div>
    </div>
    <div class="flex justify p-2">
      <div class="text-center w-1/3">終了時間</div>
      <div class="w-2/3">
        <VueTimepicker
          id="endAt"
          v-model="endedAtObject"
          class="float-left"
          name="endAt"
          input-class="form-control"
          manual-input
          hide-dropdown />
      </div>
    </div>
    <div class="flex justify p-2">
      <div class="text-center w-1/3">内容</div>
      <input
        v-model="memoContent"
        name="memoContent"
        class="border border-base-300 w-2/3 h-9 w-96 pl-2.5"
        placeholder="メモの内容" />
    </div>
    <div v-if="errorStartedAtMessage === '開始時間を入力してください'">
      <p class="text-red-500 py-2">{{ errorStartedAtMessage }}</p>
    </div>
    <div v-if="errorEndedAtMessage === '終了時間を入力してください'">
      <p class="text-red-500 py-2">{{ errorEndedAtMessage }}</p>
    </div>
    <div v-if="errorMemoMessage === '20文字以内で入力してください'">
      <p class="text-red-500 py-2">{{ errorMemoMessage }}</p>
    </div>
    <div class="flex justify-center p-2">
      <div class="pr-2">
        <button
          id="createNewStudyRecordButton"
          class="btn btn-info"
          :disabled="isAbleCreateButton"
          @click="newStudyTimeRecord()">
          作成
        </button>
      </div>
      <div>
        <button class="btn btn-info" @click="cancelCreateModal()">
          キャンセル
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import VueTimepicker from 'vue3-timepicker/src/VueTimepicker.vue'
import { useStore } from 'vuex'
import useStudyTimeRecordFunction from './functions/UseStudyTimeRecordFunction.vue'
import useValidateModal from './functions/UseValidateModal.vue'
import useFlashMessage from './functions/UseFlashMessage.vue'

export default {
  name: 'CreateStudyTimeRecord',
  components: {
    VueTimepicker
  },
  props: {
    date: {
      type: Number,
      require: true,
      default: 0
    }
  },
  setup(props) {
    const { token, createNewDate, compareStartedAtAndEndedAt } =
      useStudyTimeRecordFunction()
    const {
      errorStartedAtMessage,
      errorEndedAtMessage,
      errorMemoMessage,
      isAbleCreateButton,
      startedAtObject,
      endedAtObject,
      memoContent
    } = useValidateModal()

    const { successToast, errorToast } = useFlashMessage()
    const store = useStore()
    const startedAt = ref()
    const endedAt = ref()
    const memo = ref()

    const fetchCreateDailyStudyTimeRecords = () => {
      fetch(`/api/study_time_records`, {
        method: 'POST',
        body: JSON.stringify({
          started_at: startedAt.value,
          ended_at: endedAt.value,
          memo: memo.value
        }),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': token()
        },
        credentials: 'same-origin'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          store.commit('closeShowModal')
          store.commit('closeCreateStudyRecordModal')
          store.commit('addStudyTimeRecord', { studyTimeRecord: json })
          successToast('学習記録を作成しました')
        })
        .catch((error) => {
          console.warn(error)
          errorToast('学習記録の作成に失敗しました')
        })
    }

    const createStartAndEndDate = (atObject) => {
      return createNewDate(
          store.state.calendarYear,
          store.state.calendarMonth,
          props.date,
          atObject.value.HH,
          atObject.value.mm
      )
    }

    const newStudyTimeRecord = () => {
      startedAt.value = createStartAndEndDate(startedAtObject)
      if (endedAtObject.value === undefined) {
        endedAt.value = null
      } else {
        endedAt.value = createStartAndEndDate(endedAtObject)
        endedAt.value = compareStartedAtAndEndedAt(startedAt.value, endedAt.value)
      }
      memo.value = memoContent.value
      fetchCreateDailyStudyTimeRecords()
    }

    const cancelCreateModal = () => {
      store.commit('closeCreateStudyRecordModal')
    }

    return {
      startedAtObject,
      endedAtObject,
      memoContent,
      errorStartedAtMessage,
      errorEndedAtMessage,
      errorMemoMessage,
      isAbleCreateButton,
      newStudyTimeRecord,
      cancelCreateModal
    }
  }
}
</script>
