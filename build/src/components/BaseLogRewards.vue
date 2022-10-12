<template>
    <div class="rounded-lg">
        <div class="grid grid-cols-5 mt-3 bg-black/20 p-3" v-for="(item, index) in propsRef.log_rewards.value" :key="index">
            <div class="col-span-1 flex justify-center items-center">
                <div class="flex justify-center items-center">
                    <img class="w-12 h-12 rounded-lg" :src="`nui://esx_inventoryhud/html/img/items/${item.name}.png`" />
                </div>
            </div>
            <div class="col-span-3 flex justify-center items-center">
                <p class="text-lg truncate text-white ml-3"> {{ item.label }}</p>
            </div>
            <div class="col-span-1 flex justify-center items-center">
                <div class="w-12 h-12 bg-black/20 rounded-lg flex justify-center items-center">
                    <p class="text-lg text-white">{{ item.amount }}</p>
                </div>
            </div>
        </div>
    </div>
</template>


<script setup>
import { toRefs } from "vue";

const props = defineProps({
    log_rewards: {
        type: Object,
    }
})

const propsRef = toRefs(props)
</script>