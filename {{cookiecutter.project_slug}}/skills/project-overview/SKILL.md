{% set front_title %}
  {% if cookiecutter.frontend == 'vue' %}
    Vue 3
  {% elif cookiecutter.frontend == 'react' %}
    React 18
  {% endif %}
{% endset %}

{% set ui_lib %}
  {% if cookiecutter.frontend == 'vue' %}
    PrimeVue 4 (Aura theme)
  {% elif cookiecutter.frontend == 'react' %}
    Radix UI (shadcn/ui)
  {% endif %}
{% endset %}

---
name: project-overview
description: General description of the {{cookiecutter.project_slug}} fullstack monolith project — Django 5 + {{ front_title }} + Inertia.js + {{ ui_lib }} + Tailwind v4, goals, and stack overview.
---

# {{cookiecutter.project_slug}} — Fullstack One-App Boilerplate

## Стек

| Слой      | Технология                                     |
|-----------|-------------------------------------------------|
| Бэкенд    | Django 5.2+, Python 3.14, Gunicorn              |
| Фронтенд  | {{ front_title }} + TypeScript, Inertia.js v2   |
| UI        | {{ ui_lib }}, Tailwind CSS v4                    |
| Сборка    | Vite 8, django-vite                             |
| База      | SQLite (dev), PostgreSQL (prod через Docker)     |
| Пакеты    | uv (Python), npm (JS)                            |
| Инфра     | Docker multi-stage, nginx + supervisord          |

## Цели проекта

- **Modern Monolith** — один Django-проект без выделенных приложений, вся бизнес-логика в `{{cookiecutter.project_slug}}/`.
- **SSR на Inertia** — без SPA-маршрутизации на клиенте, рендеринг через Inertia с Vue/React.
- **Минимум бойлерплейта** — CRUD, админка, auth, RAG-пайплайны — всё через Inertia-страницы.
- **Корпоративная среда** — Artifactory как зеркало пакетов, Docker-регистри X5.
