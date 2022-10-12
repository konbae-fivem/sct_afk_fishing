<template>
    <p class="text-center text-sm text-white font-normal uppercase">RUNNING: {{ propsRef.running_time.value !== undefined ? useTimeAgo(propsRef.running_time.value).value : "UNKNOW" }}</p>
</template>

<script setup>
import { toRefs } from "vue";
import { useTimeAgo } from "@vueuse/core";

const props = defineProps({
    running_time: {
        type: Date,
    }
})

const propsRef = toRefs(props)
</script>