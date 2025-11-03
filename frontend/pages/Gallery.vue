<script setup lang="ts">
import { Card } from 'primevue';
import { Button } from 'primevue';

interface GalleryPicture {
  url: string,
  title: string,
  title_en: string,
  description: string,
  wiki_link: string,
}

defineProps({
  'pictures': Array<GalleryPicture>,
});
</script>

<template>
  <section class="gallery container mx-auto px-5 py-2 lg:px-32 lg:pt-12">
    <div class="-m-1 flex flex-wrap md:-m-2">
      <div class="flex w-1/3 flex-wrap" v-for="pic in pictures">
        <div class="w-full p-1 md:p-2">
          <Card style="width: 256px; overflow: hidden">
              <template #header>
                  <img alt="user header" :src="pic.url" width="256px" />
              </template>
              <template #title>{{ pic.title }}</template>
              <template #subtitle>{{ pic.title_en }}</template>
              <template #content>
                  <p class="m-0">{{ pic.description }}</p>
              </template>
              <template #footer>
                <Button as="a" :href="wiki_link" :label="pic.title_en">Wiki</Button>
              </template>
          </Card>
        </div>
      </div>
    </div>
  </section>
</template>
