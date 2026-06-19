---
name: django-best-practices
description: Django model definitions, Inertia views, ORM query patterns, middleware ordering, static/media config, and dataclass usage for props in the Dejavue project.
---

# Django: модели, views, ORM, middleware

## Модели

Модели определять в `dejavue/models.py`. Наследовать от `models.Model` и добавлять:

- `__str__`
- `Meta.verbose_name` / `verbose_name_plural`
- `Meta.ordering`
- `created_at`, `updated_at` через `auto_now_add` / `auto_now`

```python
class GalleryPicture(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    image = models.ImageField(upload_to='gallery/')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'фотография'
        verbose_name_plural = 'фотографии'
        ordering = ['-created_at']

    def __str__(self):
        return self.title
```

## Dataclass для пропсов Inertia

Пропсы для Inertia не обязаны быть моделями — используй `dataclasses.dataclass` или `TypedDict`, если не нужна БД.

```python
from dataclasses import dataclass

@dataclass
class GalleryPicture:
    url: str
    title: str
```

Для передачи в Inertia используй `dataclasses.asdict()`.

## ORM

- Все запросы — через менеджеры модели, никакого raw SQL без крайней нужды
- Джойны через `select_related` / `prefetch_related`
- Для аггрегаций — `annotate` / `aggregate`
- Фильтрация — через `Q`-объекты
- Пагинация — `Paginator` из Django

## Views

Все вьюхи, возвращающие страницы, — Inertia-вьюхи:

```python
from inertia import render
from django.shortcuts import redirect, get_object_or_404

def index(request):
    return render(request, 'Index', {'name': 'Dejavue'})
```

- Никаких `TemplateView` или `ListView` — только функции или `View` + `render()`
- Редиректы после мутаций — `redirect('page-name')` или `redirect('/')`
- Ошибки 404 — `get_object_or_404()`, Inertia их обернёт

## Middleware

Порядок в `settings.py` (InertiaMiddleware — последним из кастомных):

1. `SecurityMiddleware`
2. `SessionMiddleware`
3. `CommonMiddleware`
4. `CsrfViewMiddleware`
5. `AuthenticationMiddleware`
6. `MessagesMiddleware`
7. `XFrameOptionsMiddleware`
8. `inertia.middleware.InertiaMiddleware`

## Статика и медиа

```python
STATICFILES_DIRS = [DJANGO_VITE_ASSETS_PATH]  # staticfiles/dist
STATIC_ROOT = BASE_DIR / 'static'
MEDIA_ROOT = BASE_DIR / 'media'
WHITENOISE_IMMUTABLE_FILE_TEST = lambda path, url: re.match(r'^.*[0-9a-f]{8,12}\..*$', url)
```
