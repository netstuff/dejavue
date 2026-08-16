---
name: security
description: Security practices for the Django/Inertia stack — CSRF token passing, CORS config, Content Security Policy, XSS prevention, SQL injection protection, file upload validation, rate limiting, and security middleware settings.
---

# Безопасность: валидация, CSRF, CORS

## CSRF

Inertia-django автоматически добавляет CSRF-токен в `page.props.csrf_token`. Для HTML-форм пробрасывай через shared data:

```python
from django.middleware.csrf import get_token
share(request, csrf_token=get_token(request))
```

## CORS

CORS не нужен — фронтенд и бэкенд на одном домене через nginx.

```python
INSTALLED_APPS += ['corsheaders']
MIDDLEWARE.insert(0, 'corsheaders.middleware.CorsMiddleware')
CORS_ALLOWED_ORIGINS = os.getenv('CORS_ALLOWED_ORIGINS', '').split(',')
```

## Content Security Policy

Через `django-csp`:

```python
INSTALLED_APPS += ['csp.middleware.CSPMiddleware']
CSP_DEFAULT_SRC = ["'self'"]
CSP_SCRIPT_SRC = ["'self'", "'unsafe-inline'"]
CSP_STYLE_SRC = ["'self'", "'unsafe-inline'"]
CSP_IMG_SRC = ["'self'", "data:"]
```

## XSS

- Django-шаблоны и Vue экранируют вывод через `{% raw %}{{ value }}{% endraw %}`; React экранирует всё в JSX автоматически
- `v-html` (Vue) / `dangerouslySetInnerHTML` (React) использовать только с доверенным контентом + DOMPurify
- UI-компоненты (PrimeVue/shadcn) экранируют текст

## SQL Injection

- Django ORM экранирует параметры — не использовать raw SQL без крайней нужды
- Параметризованные запросы: `cursor.execute('SELECT * FROM t WHERE id = %s', [id])`

## File upload

```python
from django.core.validators import FileExtensionValidator
image = models.FileField(upload_to='uploads/', validators=[FileExtensionValidator(['jpg', 'png', 'gif', 'webp'])])
```

## Rate limiting

```python
@ratelimit(key='ip', rate='10/s')
def contact_form(request): ...
```

## Security Middleware

```python
SECURE_HSTS_SECONDS = 31536000
SECURE_SSL_REDIRECT = True       # при HTTPS
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SECURE = True     # в production
CSRF_COOKIE_HTTPONLY = True
CSRF_COOKIE_SECURE = True        # в production
X_FRAME_OPTIONS = 'DENY'
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
```
