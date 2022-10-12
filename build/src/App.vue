<template>
  <div class="transition-all duration-500 select-none" :class="InterfaceControl.show ? 'opacity-100' : 'opacity-0'">
    <div class=" flex h-screen items-center justify-start absolute m-auto left-0 right-0 ">

      <div class="flex flex-col scale-75">
        <div class="bg-black/70 w-72 rounded-lg">
          <div class="p-5">
            <div class="h-40 w-auto flex items-center justify-center bg-black/30 rounded-lg">
              <div class="text-7xl text-bold text-white">
                {{ CountFormat.format(InterfaceControl.count)}}
              </div>
            </div>

            <div class="mt-2">
              <BaseProgressbar :action="InterfaceControl.action" :duration="InterfaceControl.duration" @onProgressbarFinished="onProgressbarFinished"></BaseProgressbar>
            </div>
          </div>
        </div>

        <div class="bg-black/70 w-72 rounded-lg mt-2 p-3">
          <div class="text-center text-sm text-white font-normal" v-if="InterfaceControl.mode">
            Press
            <kbd class="px-1 py-1.2 text-sm font-semibold text-gray-800 bg-gray-100 border border-gray-200 rounded-lg dark:bg-gray-600 dark:text-gray-100 dark:border-gray-500">E</kbd>
            Enable AFK Fishing
          </div>

          <div class="text-center text-sm text-white font-normal" v-else>
            Press
            <kbd class="px-1 py-1.2 text-sm font-semibold text-gray-800 bg-gray-100 border border-gray-200 rounded-lg dark:bg-gray-600 dark:text-gray-100 dark:border-gray-500">X</kbd>
            Cancel AFK Fishing
          </div>

        </div>

        <div class="bg-black/70 w-72 rounded-lg mt-2 p-3">
          <div class="text-center text-sm text-white font-normal">
            Press
            <kbd class="px-1 py-1.2 text-sm font-semibold text-gray-800 bg-gray-100 border border-gray-200 rounded-lg dark:bg-gray-600 dark:text-gray-100 dark:border-gray-500">K</kbd>
            Change AFK Status
          </div>
        </div>
      </div>
    </div>

    <div class="flex h-screen items-center justify-end absolute m-auto left-0 right-0 ">

      <div class="flex flex-col scale-75">
        <div class="bg-black/70 w-80 rounded-lg">
          <div class="p-5">
            <p class="text-center text-lg text-white font-normal uppercase mb-1">Log Rewards</p>

            <div v-if="InterfaceControl.log_rewards.length > 0">
              <BaseLogRewards :log_rewards="InterfaceControl.log_rewards"></BaseLogRewards>
            </div>
            <div v-else>
              <p class="text-center text-xs text-white font-normal uppercase mt-3">empty reward</p>
            </div>
          </div>
        </div>

        <div class="bg-black/70 w-80 rounded-lg mt-2 p-2">
          <BaseRunningTime :running_time="InterfaceControl.running_timer"></BaseRunningTime>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import BaseProgressbar from "./components/BaseProgressbar.vue";
import BaseLogRewards from "./components/BaseLogRewards.vue";
import BaseRunningTime from "./components/BaseRunningTime.vue";

import { reactive, onMounted, onUnmounted } from "vue";
import { emitClient } from "./utils/fivem";

const CountFormat = Intl.NumberFormat("en", { notation: "compact" });

const InterfaceControl = reactive({
  show: false,
  config: {},
  count: 0,
  mode: false,
  action: 0,
  duration: 0,
  running_timer: undefined,
  interval: undefined,
  log_rewards: []
})

const onProgressbarFinished = async () => {
  InterfaceControl.action = 0
  InterfaceControl.duration = 0
  InterfaceControl.count++

  emitClient("sct_afk_fishing", "ActionFinished")

  InterfaceControl.interval = setTimeout(() => {
    if (InterfaceControl.mode) {
      InterfaceControl.action = 100
      InterfaceControl.duration = InterfaceControl.config.DurationGetReward
    }
  }, 100);
}

const handleMessage = async (event) => {
  const { action, data } = event.data;

  if (action === "OPEN_INTERFACE") {
    InterfaceControl.show = true
    InterfaceControl.config = data.config
  }

  if (action === "START_ACTION") {
    InterfaceControl.mode = true
    InterfaceControl.running_timer = new Date()
    InterfaceControl.log_rewards = []
    InterfaceControl.action = 100
    InterfaceControl.duration = InterfaceControl.config.DurationGetReward
  }

  if (action === "STOP_ACTION") {
    InterfaceControl.mode = false
    InterfaceControl.running_timer = undefined
    InterfaceControl.action = 0
    InterfaceControl.duration = 0
    clearTimeout(InterfaceControl.interval)
  }

  if (action === "UPDATE_LOG_REWARD") {
    let index = InterfaceControl.log_rewards.findIndex((item => item.label === data.label))
    if (index === -1) {
      InterfaceControl.log_rewards.push(data)
    } else {
      InterfaceControl.log_rewards[index].amount = InterfaceControl.log_rewards[index].amount + data.amount
    }
  }

  if (action === "CLOSE_INTERFACE") {
    InterfaceControl.show = false
  }
}

onMounted(() => {
  window.addEventListener("message", handleMessage);
});

onUnmounted(() => {
  window.removeEventListener("message", handleMessage);
});
</script>

<style scoped>
::-webkit-scrollbar {
  display: none;
}
</style>