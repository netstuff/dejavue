---
name: frontend-vue
description: Vue 3 Composition API conventions, PrimeVue 4 component usage, Tailwind CSS v4 styling, file organization (pages/components/composables/types), Vite config, and TypeScript typing for Inertia props.
---

# Vue 3 + PrimeVue + Tailwind CSS v4

## Компоненты

- Composition API + `<script setup lang="ts">` — стандарт
- Props — `defineProps<Type>()` с TypeScript
- Emits — `defineEmits<{ (e: 'click', id: number): void }>()`
- Refs — `ref()` / `computed()` / `watch()`
- В шаблонах — PascalCase для компонентов PrimeVue

## Типизация пропсов из Inertia

```vue
<script setup lang="ts">
interface Post { id: number; title: string; body: string }
defineProps<{ posts: Post[] }>()
</script>
```

## Стилизация

- Tailwind v4 — глобально через `@import "tailwindcss"` в `frontend/style.css`
- Кастомизация через `@theme` в CSS, не через `tailwind.config.js`
- PrimeVue-компоненты стилизуются через `pt`-prop или CSS-переменные

```vue
<template>
  <Card class="max-w-md mx-auto mt-8">
    <template #title>Заголовок</template>
    <template #content>
      <p class="text-sm text-gray-600">Описание</p>
      <Button label="Сохранить" icon="pi pi-check" class="mt-4" />
    </template>
  </Card>
</template>
```

## Организация файлов

```
frontend/
  pages/                # Inertia-страницы (одна страница = один файл)
    Index.vue
    Users/
      Index.vue
  components/           # Переиспользуемые компоненты
    ui/                 # Тонкие обёртки над PrimeVue
    layout/
      AppLayout.vue
  composables/          # Композаблы (useAuth, useFlash)
  types/                # TypeScript-типы
  main.ts               # Точка входа
  style.css             # Tailwind entry
```

## Композаблы

```typescript
export function useCounter(initial = 0) {
  const count = ref(initial)
  const increment = () => count.value++
  return { count, increment, decrement }
}
```

## Vite

- Root: `./frontend`, Base: `/static/`, Output: `staticfiles/dist/`
- Плагины: `vue()` + `tailwindcss()`
- `django-vite` подхватывает манифест для production

## Навигация без форм

```typescript
import { router } from '@inertiajs/vue3'
router.get('/users', { page: 2 }, { preserveState: true })
router.delete(`/users/${id}`)
```
