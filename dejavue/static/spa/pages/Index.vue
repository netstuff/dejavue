<template>
  <div>
    <h1 class="title">Hello world from {{ name }}!</h1>
    <button @click="increment">Add</button>
    <p>Count: {{ count }}</p>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";

defineProps<{
  name: string;
}>();

const count = ref(0);
function increment() {
  count.value++;
}

const double = computed(() => count.value * 2);
</script>
