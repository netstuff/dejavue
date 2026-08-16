---
name: django-architecture
description: Architecture principles of the Modern Monolith — single Django project without apps, request flow through nginx/Gunicorn/Inertia/Vue, page structure conventions.
---

# Архитектурные принципы (Modern Monolith)

## Один проект, без django-приложений

Весь код лежит в корневом пакете `{{cookiecutter.project_slug}}/`. В нём нет `models.py` или `apps.py` — модели определяются по мере необходимости.

```
{{cookiecutter.project_slug}}/
  __init__.py
  settings.py
  urls.py
  views.py
  asgi.py
  wsgi.py
  templates/
    index.html           # Inertia layout (корневой шаблон)
```

## Поток запроса

```
Browser → nginx :80 → Gunicorn :8000 → Django → Inertia render → Vue/React page
                          ↑                            ↓
                     django-vite               Vite / staticfiles
```

1. Браузер запрашивает `/` → nginx проксирует на Gunicorn
2. Django обрабатывает, вызывает `inertia.render(request, 'PageName', props)`
3. Inertia-django рендерит `templates/index.html` с data-атрибутами
4. Клиентский фронтенд (Vue/React) подхватывает и монтирует компонент страницы
5. Последующие переходы — Inertia-навигация (fetch без полной перезагрузки)

## Inertia вместо REST

- Нет API-эндпоинтов для SPA — все страницы возвращаются через `inertia.render()`
- Нет сериализаторов (DRF) — пропсы передаются простыми dict/objects
- GET-запросы возвращают Inertia-ответ с props, POST/PUT/DELETE обрабатываются и редиректят

## Структура страниц

{% if cookiecutter.frontend == 'vue' %}
```
frontend/pages/
  Index.vue       → inertia.render('Index', props)
  Users/          → страницы, сгруппированные по домену
    Index.vue
    Edit.vue
```
{% elif cookiecutter.frontend == 'react' %}
```
frontend/app/components/
  Index.tsx       → inertia.render('Index', props)
  Users/          → страницы, сгруппированные по домену
    Index.tsx
    Edit.tsx
```
{% endif %}

Название страницы в компоненте (Vue-файл / `tsx`-компонент) должно совпадать со строкой, переданной в `inertia.render()`.
