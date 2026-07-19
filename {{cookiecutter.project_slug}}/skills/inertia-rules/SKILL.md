---
name: inertia-rules
description: Inertia.js patterns — server-side render calls, shared data via middleware, Inertia links, useForm for mutations, flash messages, CSRF token handling, and 404/500 error handling.
---

# Inertia.js: роутинг, shared data, формы

## Базовая страница

```python
from inertia import render

def dashboard(request):
    return render(request, 'Dashboard', {'stats': stats})
```

```vue
<script setup lang="ts">
defineProps<{ stats: { users_count: number; posts_count: number } }>()
</script>
```

Всегда указывай пропсы явно через `defineProps`.

## Shared data

Данные на все страницы задаются через `Inertia.share()` — обычно в middleware:

```python
from inertia import share

class ShareUserMiddleware:
    def __call__(self, request):
        if request.user.is_authenticated:
            share(request, user={'id': request.user.id, 'name': request.user.get_full_name()})
        else:
            share(request, user=None)
        return self.get_response(request)
```

На клиенте доступно через `usePage().props.user`.

## Навигация

```vue
<script setup lang="ts">
import { Link } from '@inertiajs/vue3'
</script>

<template>
  <Link href="/dashboard">Dashboard</Link>
  <Link href="/users" :data="{ page: 2 }">Page 2</Link>
  <Link href="/users" method="post" as="button">Create</Link>
</template>
```

## Формы (useForm)

```vue
<script setup lang="ts">
import { useForm } from '@inertiajs/vue3'
const form = useForm({ title: '', body: '' })
function submit() { form.post('/posts', { onSuccess: () => form.reset() }) }
</script>
<template>
  <form @submit.prevent="submit">
    <input v-model="form.title" />
    <div v-if="form.errors.title">{{ form.errors.title }}</div>
    <button :disabled="form.processing">Save</button>
  </form>
</template>
```

## Редиректы после мутаций

```python
def create_post(request):
    Post.objects.create(title=request.POST['title'])
    return redirect('dashboard')
```

## Flash-уведомления

```python
# middleware
share(request, flash={'success': request.session.pop('success', None)})
```

На клиенте: `usePage().props.flash`.

## CSRF

Inertia-django автоматически добавляет CSRF-токен в `page.props.csrf_token`. Для обычных HTML-форм пробрасывай через shared data:

```python
share(request, csrf_token=get_token(request))
```

## Обработка ошибок

Inertia автоматически обрабатывает 404/500 через исключения Django. Ошибки валидации передаются через `form.errors`.
