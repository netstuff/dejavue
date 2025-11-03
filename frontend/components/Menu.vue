<script setup lang="ts">
import {
  NavigationMenuIndicator,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  NavigationMenuRoot,
  NavigationMenuViewport,
} from 'reka-ui';
import { ref } from 'vue';
import { Link } from '@inertiajs/vue3';

const currentTrigger = ref('')
</script>

<template>
  <NavigationMenuRoot
    v-model="currentTrigger"
    class="relative z-[1] flex w-full justify-center"
  >
    <NavigationMenuList class="center m-0 flex list-none rounded-lg bg-white p-1 shadow-sm border">
      <NavigationMenuItem>
        <Link href="/">Index</Link>
      </NavigationMenuItem>
      <span class="separator">|</span>
      <NavigationMenuItem>
        <Link href="/gallery">Gallery</Link>
      </NavigationMenuItem>

      <NavigationMenuIndicator
        class="absolute data-[state=hidden]:opacity-0 duration-200 data-[state=visible]:animate-fadeIn data-[state=hidden]:animate-fadeOut top-full w-[--reka-navigation-menu-indicator-size] translate-x-[--reka-navigation-menu-indicator-position] mt-[1px] z-[100] flex h-[10px] items-end justify-center overflow-hidden transition-[all,transform_250ms_ease]"
      >
        <div class="relative top-[70%] h-[12px] w-[12px] rotate-[45deg] bg-white border" />
      </NavigationMenuIndicator>
    </NavigationMenuList>

    <div class="perspective-[2000px] absolute top-full left-0 flex w-full justify-center ">
      <NavigationMenuViewport
        class="data-[state=open]:animate-scaleIn data-[state=closed]:animate-scaleOut relative mt-[10px] h-[var(--reka-navigation-menu-viewport-height)] w-full origin-[top_center] overflow-hidden rounded-xl bg-white transition-[width,_height] duration-300 sm:w-[var(--reka-navigation-menu-viewport-width)] border shadow-sm"
      />
    </div>
  </NavigationMenuRoot>
</template>

<style>
nav {
  padding: 5px 0;
}

nav li {
  padding: 0 5px;
}
</style>