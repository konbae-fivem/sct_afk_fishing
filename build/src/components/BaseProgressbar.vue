<template>
    <div class="w-full bg-gray-700 rounded-full h-2.5 mt-1">
        <div class="bg-blue-600 h-2.5 rounded-full" :style="{ width: `${ProgressOutput}%` }"></div>
    </div>
</template>


<script setup>
import { toRefs } from "vue";
import { useTransition, TransitionPresets } from "@vueuse/core";

const emit = defineEmits(["onProgressbarFinished"])

const props = defineProps({
    action: {
        type: Number,
        default: 0,
        required: true,
    },
    duration: {
        type: Number,
        default: 0,
        required: true,
    }
})

const propsRef = toRefs(props)

const ProgressOutput = useTransition(propsRef.action, {
    duration: propsRef.duration,
    transition: TransitionPresets.linear,
    onFinished() {
        if (propsRef.action.value === 100) {
            emit("onProgressbarFinished")
        }
    }
});

</script>