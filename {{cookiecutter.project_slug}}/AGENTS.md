{% set front_title %}
  {% if cookiecutter.frontend == 'vue' %}
    Vue 3
  {% elif cookiecutter.frontend == 'react' %}
    React 18
  {% endif %}
{% endset %}

{% set front_ext %}
  {% if cookiecutter.frontend == 'react' %}
    tsx
  {% else %}
    ts
  {% endif %}
{% endset %}


# AGENTS.md — Руководство для AI-агентов

## Стек проекта (актуальный)

| Слой      | Технология                                                |
|-----------|-----------------------------------------------------------|
| Бэкенд    | Django 5.2+, Python 3.14, Gunicorn                        |
| Фронтенд  | {{ front_title }} + TypeScript, Inertia.js v2             |
| UI        | Radix UI (shadcn/ui), Tailwind CSS v4                     |
| Сборка    | Vite 6, django-vite                                       |
| База      | SQLite (dev), PostgreSQL (prod через Docker)              |
| Пакеты    | uv (Python), npm (JS)                                     |
| Инфра     | Docker multi-stage, nginx + supervisord                   |

## Структура проекта

```
{{cookiecutter.project_slug}}/                  # Django-пакет (монолит, без приложений)
  settings.py
  urls.py
  views.py                     # Inertia-вьюхи
  templates/
    index.html                 # Inertia layout (корневой шаблон)
frontend/                      # {{ front_title }} SPA (Vite root)
  main.{{ front_ext}}                     # Точка входа
  styles/
    index.css                  # Tailwind entry (@import "tailwindcss")
skills/                        # Инструкции по кодстайлу и паттернам
deploy/                        # Docker, nginx, supervisord конфиги
```

## Архитектура: Modern Monolith

- Один Django-проект `{{cookiecutter.project_slug}}/`, **без выделенных приложений** (нет `apps.py`).
- Весь код в корневом пакете: модели, вьюхи, URL-ы.
- Нет REST API — все страницы через `inertia.render(request, 'PageName', props)`.
- Нет DRF-сериализаторов — пропсы передаются как dict или `dataclasses.asdict()`.

### Поток запроса

```
Browser → Django → inertia.render('Page', props) → templates/index.html → {{ front_title }} (Inertia client)
                                  ↓
                            django-vite (dev: HMR, prod: staticfiles)
```

## Важные расхождения Skills vs Реальность

Файлы в `skills/` созданы из шаблона **Vue 3**. Проект использует **{{ front_title }}**. Фронтенд-паттерны описаны в `skills/frontend-{{ cookiecutter.frontend }}/SKILL.md`. Vue-примеры в `common-tasks`, `inertia-rules`, `testing-django-vue`.

## Навыки (skills/) и когда их применять

### project-overview
**Файл:** `skills/project-overview/SKILL.md`
**Когда:** Первичное знакомство с проектом. Общая архитектура и цели.

### django-architecture
**Файл:** `skills/django-architecture/SKILL.md`
**Когда:** Создание новых вьюх, URL-маршрутов, структуры страниц.
**Применение:** Паттерн Inertia-вьюх, структура страниц, поток запросов — **актуально для React**. Шаблоны страниц (`frontend/pages/`) — **устарело**, сейчас `frontend/app/components/`.

### django-best-practices
**Файл:** `skills/django-best-practices/SKILL.md`
**Когда:** Определение моделей, написание вьюх, ORM-запросов, middleware.
**Применение:** Модели (`drone_motors/models.py`), dataclass для пропсов, ORM-паттерны, middleware ordering — **полностью актуально**.

### code-style
**Файл:** `skills/code-style/SKILL.md`
**Когда:** Любая генерация кода — Python и TypeScript.
**Применение:** Python (Ruff, snake_case, аннотации) — **актуально**. Django-специфика (urls, views, models) — **актуально**. Inertia-специфика (PascalCase страницы) — **актуально**. TypeScript-часть — **адаптировать**: вместо Vue-конвенций использовать React-конвенции (camelCase переменные, PascalCase компоненты, `.tsx` расширение).

### common-tasks
**Файл:** `skills/common-tasks/SKILL.md`
**Когда:** CRUD, авторизация, поиск, пагинация, загрузка файлов.
**Применение:** Python-паттерны (вьюхи, ORM, redirect) — **актуально**. Vue-шаблоны — **адаптировать под React**: `useForm` из `@inertiajs/react`, JSX вместо `<template>`, `router` из `@inertiajs/react`.

### inertia-rules
**Файл:** `skills/inertia-rules/SKILL.md`
**Когда:** Роутинг, shared data, формы, flash-уведомления, CSRF.
**Применение:** Серверная часть (Python, `inertia.render`, `share()`) — **полностью актуально**. Клиентская часть — **адаптировать под React**: `Link` из `@inertiajs/react`, `useForm` из `@inertiajs/react`, `usePage().props`.

### security
**Файл:** `skills/security/SKILL.md`
**Когда:** CSRF, CORS, XSS, валидация файлов, rate limiting.
**Применение:** **Полностью актуально** — серверная безопасность не зависит от фреймворка фронта.

### testing-django-vue
**Файл:** `skills/testing-django-vue/SKILL.md`
**Когда:** Написание тестов.
**Применение:** Python-тесты (pytest, test views, test models) — **актуально**. Vue-тесты — **адаптировать**: Vitest + `@testing-library/react` вместо `@vue/test-utils`.

### deployment
**Файл:** `skills/deployment/SKILL.md`
**Когда:** Docker, nginx, supervisord, переменные окружения.
**Применение:** **Полностью актуально** — инфраструктура не зависит от фреймворка фронта.

### frontend-react
**Файл:** `skills/frontend-react/SKILL.md`
**Когда:** Фронтенд-компоненты, стилизация, Vite-конфиг, шаблоны React + Inertia.
**Применение:** **Полностью актуально** — React-компоненты, shadcn/ui, Tailwind v4, Inertia React (Link, useForm, usePage), типизация пропсов, навигация, формы.

## Паттерны для генерации кода

### Inertia-вьюха (Python)

```python
from inertia import render
from django.shortcuts import get_object_or_404

def page_name(request):
    return render(request, 'PageName', {'key': value})
```

### React-компонент (Inertia-страница)

```tsx
interface Props {
  key: string;
}

export default function PageName({ key }: Props) {
  return <div>{key}</div>;
}
```

### Форма (React + Inertia)

```tsx
import { useForm } from '@inertiajs/react';

export default function CreateForm() {
  const { data, setData, post, processing, errors } = useForm({ title: '' });

  function submit(e: React.FormEvent) {
    e.preventDefault();
    post('/create');
  }

  return (
    <form onSubmit={submit}>
      <input value={data.title} onChange={e => setData('title', e.target.value)} />
      {errors.title && <span>{errors.title}</span>}
      <button disabled={processing}>Save</button>
    </form>
  );
}
```

### Навигация

```tsx
import { Link, router } from '@inertiajs/react';

<Link href="/page">Text</Link>
router.get('/page', { param: 'value' }, { preserveState: true });
router.delete(`/items/${id}`);
```

## Команды

```bash
make dev          # Запуск backend (:8000) + frontend (:5173)
make dev-backend  # Только Django dev-сервер
make dev-frontend # Только Vite dev-сервер
make build        # Сборка для production
make test         # Backend тесты (pytest)
make lint         # Linting (ruff + mypy)
```

## Чек-лист перед коммитом

1. Python: `uv run ruff check` — нет ошибок линтера
2. Python: аннотации типов на новых функциях
3. TypeScript: `npm run build` — нет ошибок компиляции
4. React: компоненты в `frontend/app/components/`
5. Inertia: имя страницы в `render()` совпадает с именем компонента
6. Без секретов и ключей в коде

## Логирование запросов

Все пользовательские запросы последовательно записываются в файл `.history/queries.md`. Формат:

```markdown
## YYYY-MM-DD HH:MM — <краткое описание запроса>

<полный текст запроса>

---
```

Пример:

```markdown
## 2025-07-21 14:30 — Исправление ошибки preamble

Исправь ошибку при запуске
```
Uncaught Error: @vitejs/plugin-react can't detect preamble. Something is wrong.
```

---
```

Запись ведётся **после каждого пользовательского запроса** (append в конец файла). Файл создаётся автоматически при первом запросе.
