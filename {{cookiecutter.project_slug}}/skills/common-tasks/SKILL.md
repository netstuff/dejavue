---
name: common-tasks
description: Reusable code patterns for common tasks — CRUD list/detail/create/edit/delete, authentication with shared data, search/filter with Inertia, pagination, file uploads with forceFormData, and RAG/LLM integration.
---

# Шаблоны для частых задач

## CRUD — список + детальная

```python
def post_list(request):
    posts = list(Post.objects.values('id', 'title', 'created_at'))
    return render(request, 'Posts/Index', {'posts': posts})

def post_detail(request, pk):
    post = get_object_or_404(Post, pk=pk)
    return render(request, 'Posts/Detail', {'post': post})
```

{% if cookiecutter.frontend == 'vue' %}
```vue
<script setup lang="ts">
import { Link } from '@inertiajs/vue3'
interface Post { id: number; title: string; created_at: string }
defineProps<{ posts: Post[] }>()
</script>
<template>
  <div v-for="post in posts" :key="post.id">
    <Link :href="`/posts/${post.id}`">{{ post.title }}</Link>
  </div>
</template>
```
{% elif cookiecutter.frontend == 'react' %}
```tsx
import { Link } from '@inertiajs/react'

interface Post { id: number; title: string; created_at: string }

interface Props {
  posts: Post[]
}

export default function PostsIndex({ posts }: Props) {
  return (
    <>
      {posts.map(post => (
        <div key={post.id}>
          <Link href={`/posts/${post.id}`}>{post.title}</Link>
        </div>
      ))}
    </>
  )
}
{% endif %}

## CRUD — создание / редактирование

```python
def post_create(request):
    if request.method == 'POST':
        post = Post.objects.create(title=request.POST['title'], body=request.POST['body'])
        return redirect('post_detail', pk=post.pk)
    return render(request, 'Posts/Create')
```

{% if cookiecutter.frontend == 'vue' %}
```vue
<script setup lang="ts">
import { useForm } from '@inertiajs/vue3'
const form = useForm({ title: '', body: '' })
</script>
<template>
  <form @submit.prevent="form.post('/posts')">
    <InputText v-model="form.title" />
    <Button label="Save" type="submit" :loading="form.processing" />
  </form>
</template>
```
{% elif cookiecutter.frontend == 'react' %}
```tsx
import { useForm } from '@inertiajs/react'
import { InputText } from '@/components/ui/input'
import { Button } from '@/components/ui/button'

interface Props {
  post?: { id: number; title: string; body: string }
}

export default function PostForm({ post }: Props) {
  const { data, setData, post, processing, errors } = useForm({
    title: post?.title ?? '',
    body: post?.body ?? '',
  })

  function submit(e: React.FormEvent) {
    e.preventDefault()
    post(post ? `/posts/${post.id}` : '/posts')
  }

  return (
    <form onSubmit={submit}>
      <InputText value={data.title} onChange={e => setData('title', e.target.value)} />
      {errors.title && <span>{errors.title}</span>}
      <Button type="submit" disabled={processing}>Save</Button>
    </form>
  )
}
```
{% endif %}


## CRUD — удаление

```python
def post_delete(request, pk):
    get_object_or_404(Post, pk=pk).delete()
    return redirect('post_list')
```

```typescript
router.delete(`/posts/${id}`)
```

## Auth

```python
def login_view(request):
    if request.method == 'POST':
        user = authenticate(request, username=request.POST['username'], password=request.POST['password'])
        if user:
            login(request, user)
            return redirect('dashboard')
        return render(request, 'Login', {'errors': {'auth': 'Invalid credentials'}})
    return render(request, 'Login')
```

{% if cookiecutter.frontend == 'vue' %}
```vue
<script setup lang="ts">
import { usePage, Link } from '@inertiajs/vue3'
const auth = usePage().props.auth as { user: { id: number; name: string } | null }
</script>
```
{% elif cookiecutter.frontend == 'react' %}
```tsx
import { usePage, Link } from '@inertiajs/react'

export default function Login() {
  const auth = usePage().props.auth as { user: { id: number; name: string } | null }

  return auth.user ? (
    <Link href={`/users/${auth.user.id}`}>{auth.user.name}</Link>
  ) : (
    <Link href="/login">Login</Link>
  )
}
```
{% endif %}


## Поиск / фильтрация

```python
def post_list(request):
    query = request.GET.get('q', '')
    posts = Post.objects.filter(title__icontains=query) if query else Post.objects.all()
    return render(request, 'Posts/Index', {'posts': list(posts.values('id', 'title')), 'query': query})
```

{% if cookiecutter.frontend == 'vue' %}
```vue
<script setup lang="ts">
import { router } from '@inertiajs/vue3'
const search = ref(props.query)
function onSearch() { router.get('/posts', { q: search.value }, { preserveState: true }) }
</script>
```
{% elif cookiecutter.frontend == 'react' %}
```tsx
import { router } from '@inertiajs/react'
import { useState } from 'react'

interface Props {
  query: string
}

export default function PostsIndex({ query }: Props) {
  const [search, setSearch] = useState(query)

  function onSearch() {
    router.get('/posts', { q: search }, { preserveState: true })
  }

  return (
    <input
      value={search}
      onChange={e => setSearch(e.target.value)}
      onKeyDown={e => e.key === 'Enter' && onSearch()}
    />
  )
}
```
{% endif %}

## Пагинация

```python
from django.core.paginator import Paginator
paginator = Paginator(Post.objects.all(), 20)
page = paginator.get_page(request.GET.get('page', 1))
```

## RAG / LLM

```python
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
context = '\n'.join(f"{p['title']}: {p['body'][:500]}" for p in posts)
response = client.chat.completions.create(model='gpt-4o-mini', messages=[...])
```

## Загрузка файлов

На клиенте: `form.post('/upload', { forceFormData: true })` — Inertia отправит как multipart/form-data.
