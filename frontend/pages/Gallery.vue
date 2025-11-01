<script setup lang="ts">
import { Link } from '@inertiajs/vue3';

defineProps(['pictures']);
</script>

<template>
  <Link href="/">Back home</Link>
  <div class="gallery">
    <div class="picture" v-for="picUrl in pictures">
      <img :src="picUrl" width="300px" />
    </div>
  </div>
</template>

<style lang="css">
.gallery {

}

.gallery > .picture {
  width: 300px;
  height: 200px;
}
</style>