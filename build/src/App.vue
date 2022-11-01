<template>
  <div class="transition-all duration-500 select-none" :class="InterfaceControl.show ? 'opacity-100' : 'opacity-0'">
    <div class="flex h-screen justify-between items-center relative sm:scale-50 md:scale-75 lg:scale-75 scale-90">

      <div class="w-64">
        <div class="bg-black/70 rounded-lg">
          <div class="p-4">
            <div class="h-40 w-auto flex items-center justify-center bg-black/30 rounded-lg">
              <div class="text-8xl text-bold text-white">
                {{ CountFormat.format(InterfaceControl.count) }}
              </div>
            </div>
            <div class="w-full bg-white rounded-full h-2.5 mt-3">
              <div id="processbar" class="bg-blue-600 h-2.5 rounded-full" style="width: 0%"></div>
            </div>

            <div class="text-center text-sm text-white font-normal mt-3">
              Press
              <kbd class="px-1 py-1.2 text-sm font-semibold text-gray-800 bg-gray-100 border border-gray-200 rounded-lg dark:bg-gray-600 dark:text-gray-100 dark:border-gray-500">X</kbd>
              Cancel AFK Fishing
            </div>
          </div>
        </div>
      </div>


      <div class="w-72 transition-all duration-500 select-none" :class="InterfaceControl.log_rewards.length > 0 ? 'opacity-100' : 'opacity-0'">
        <div class="bg-black/70 rounded-lg">
          <p class="text-center text-lg text-white font-normal uppercase">Log Rewards</p>
          <div class="p-5 bg-black/20">


            <div class="flex flex-col gap-y-3">
              <div class="flex justify-between" v-for="item in InterfaceControl.log_rewards" :key="item.label">

                <div class="flex-1 justify-center items-center">
                  <img class="w-12 h-12 rounded-lg" :src="`nui://esx_inventoryhud/html/img/items/${item.name}.png`" />
                </div>

                <div class="flex-auto flex justify-center items-center">
                  <p class="text-lg truncate text-white ml-3">{{ item.label }}</p>
                </div>

                <div class="flex-1 flex justify-center items-center rounded-lg">
                  <p class="text-lg text-white ">{{ CountFormat.format(item.amount) }}</p>
                </div>

              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { gsap, Power0 } from "gsap"
import { reactive, onMounted, onUnmounted } from "vue";
import { emitClient } from "./utils/fivem";

const CountFormat = Intl.NumberFormat("en", { notation: "compact" });

const InterfaceControl = reactive({
  show: false,
  config: null,
  count: 0,
  mode: false,
  log_rewards: [],
  timer: null
})

const startTimer = async () => {
  InterfaceControl.timer = gsap.to('#processbar', {
    width: '100%', duration: InterfaceControl.config.DurationGetReward, ease: Power0.easeNone, onComplete: () => {
      if (InterfaceControl.mode) {
        InterfaceControl.count++
        emitClient("sct_afk_fishing", "ActionFinished")
        stopTimer()
      }
    }
  })
}

const stopTimer = async () => {
  InterfaceControl.timer = gsap.to("#processbar", {
    width: '0%', duration: 0.1, ease: Power0.easeNone, onComplete: () => {
      if (InterfaceControl.mode) {
        startTimer()
      }
    }
  })
}

const onMessages = async (event) => {
  const { action, data } = event.data

  if (action === "OPEN_INTERFACE") {
    InterfaceControl.show = true
    InterfaceControl.config = data.config
    InterfaceControl.count = 0
    InterfaceControl.mode = false
    InterfaceControl.timer = null
  }

  if (action === "ACTION_INTERFACE") {
    InterfaceControl.mode = data
    if (InterfaceControl.timer) {
      InterfaceControl.timer.kill()
      InterfaceControl.timer = null
    }

    if (!InterfaceControl.mode) {
      stopTimer()
    } else {
      InterfaceControl.count = 0
      InterfaceControl.log_rewards = []
      startTimer()
    }
  }

  if (action === "UPDATE_LOG_INTERFACE") {
    let index = InterfaceControl.log_rewards.findIndex((item => item.label === data.label))
    if (index === -1) {
      InterfaceControl.log_rewards.push(data)
    } else {
      InterfaceControl.log_rewards[index].amount = InterfaceControl.log_rewards[index].amount + data.amount
    }
  }

  if (action === "CLOSE_INTERFACE") {
    InterfaceControl.show = false
    InterfaceControl.count = 0
    InterfaceControl.mode = false
    InterfaceControl.timer = null
  }
}

onMounted(() => {
  window.addEventListener("message", onMessages);
})
onUnmounted(() => {
  window.removeEventListener("message", onMessages);
})
</script>