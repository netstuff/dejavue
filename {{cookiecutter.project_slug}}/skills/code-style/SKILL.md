---
name: code-style
description: Naming and formatting conventions for Python (Ruff, snake_case, type annotations) and TypeScript/Vue (camelCase, PascalCase for components), Django-specific naming for urls/views/models, Inertia page naming rules.
---

# Соглашения по именованию, форматированию

## Python

- **Форматирование**: Ruff (`ruff format`), строка 110 символов
- **Импорты**: Ruff сортирует (`ruff check --fix`)
- **Типизация**: Аннотации типов обязательны для новых функций и методов
- **Именование**:
  - `snake_case` — переменные, функции, методы
  - `PascalCase` — классы, dataclass-ы
  - `UPPER_CASE` — константы
  - `_private` — с подчёркивания для внутренних методов
  - Одиночное подчёркивание `_` — неиспользуемая переменная
  - Двойное `__dunder__` — только для магических методов
- **Докстринги**: не писать без необходимости — код должен быть самодокументируемым

## TypeScript / Vue

- **Форматирование**: Prettier или ESLint (добавить при необходимости)
- **Типизация**: `strict` mode, интерфейсы через `interface`, алиасы через `type`
- **Именование**:
  - `camelCase` — переменные, функции, методы, props, emits
  - `PascalCase` — компоненты, интерфейсы, типы
  - `kebab-case` — файлы Vue-компонентов (но в импортах PascalCase)
  - `snake_case` — только если зеркалирует Python-поле (пропсы из Django)
- **Файлы**:
  - `.vue` — однофайловые компоненты (SFC)
  - `.ts` — TypeScript-модули (композаблы, типы, утилиты)

## TypeScript / React

- **Форматирование**: Prettier или ESLint (добавить при необходимости)
- **Типизация**: `strict` mode, интерфейсы через `interface`, алиасы через `type`
- **Именование**:
  - `camelCase` — переменные, функции, методы, props
  - `PascalCase` — компоненты, интерфейсы, типы
  - `snake_case` — только если зеркалирует Python-поле (пропсы из Inertia)
- **Файлы**:
  - `.tsx` — React-компоненты (JSX)
  - `.ts` — TypeScript-модули (хуки, типы, утилиты)

## Django-специфика

- `urls.py` — имена маршрутов в `snake_case` через `app_name=''`
- `views.py` — функции-вьюхи в `snake_case`
- `models.py` — классы в `PascalCase`, поля в `snake_case`
- Миграции — авто-именование от makemigrations

## Inertia-специфика

- Имена страниц (аргумент `inertia.render`) — PascalCase, совпадают с именем компонента: `'Index'` → `pages/Index.vue` (Vue) или `components/Index.tsx` (React)
- Пропсы — `snake_case` на сервере → `camelCase` на клиенте (конвертируется автоматически)
- Имена маршрутов — `snake_case`

## Git

- Ветки: `feature/xxx`, `fix/xxx`, `chore/xxx`
- Коммиты: conventional commits (`feat:`, `fix:`, `chore:`, `docs:`)
- pre-commit: проверяет import order, форматирование, названия тестов
