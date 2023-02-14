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
    <div class="flex justify-center p-2">
      <div class="pr-2">
        <button
            class="btn btn-info">
          保存
        </button>
      </div>
      <div>
        <button
            class="btn btn-info"
            @click="cancelEditModal()"
        >
          キャンセル
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import VueTimepicker from 'vue3-timepicker/src/VueTimepicker.vue'
import useValidateModal from './functions/UseValidateModal.vue'
import { useStore } from 'vuex'

export default {
  name: "EditStudyTimeRecord",
  components: {
    VueTimepicker
  },
  setup() {
    const { startedAtObject, endedAtObject } = useValidateModal()
    const store = useStore()

    const cancelEditModal = () => {
      store.commit('closeEditStudyRecordModal')
    }

    return {
      startedAtObject,
      endedAtObject,
      cancelEditModal
    }
  }
}
</script>
