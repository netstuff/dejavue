---
name: deployment
description: Docker multi-stage build (backend/frontend/final), nginx config with error_log and temp paths for non-root user, supervisord config for gunicorn+nginx, env vars list, Artifactory mirrors for corporate environment.
---

# Docker, переменные окружения

## Dockerfile (multi-stage)

Три этапа: backend (uv pip install), frontend (npm run build), final (склейка).

```dockerfile
FROM python:3.11-alpine as backend
COPY pyproject.toml uv.lock* ./
RUN uv pip install --system --no-cache -r pyproject.toml

FROM node:22-alpine as frontend
COPY package.json package-lock.json ./
RUN npm install && npm run build

FROM python:3.11-alpine
RUN apk add --no-cache supervisor nginx
COPY --from=backend /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=backend /usr/local/bin /usr/local/bin
COPY --from=frontend /app/staticfiles /app/staticfiles
COPY . .
RUN mkdir -p /var/lib/nginx/logs && chown -R django:django /var/lib/nginx
COPY deploy/nginx.conf /etc/nginx/nginx.conf
COPY deploy/supervisord.conf /etc/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
```

## Supervisord

```ini
[supervisord]
nodaemon=true
user=django

[program:gunicorn]
command=gunicorn --bind 0.0.0.0:8000 --workers 2 --threads 2 {{cookiecutter.project_slug}}.wsgi:application
user=django
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr

[program:nginx]
command=nginx -g "daemon off;"
user=django
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr
```

## Nginx

```nginx
error_log /dev/stderr;
pid /tmp/nginx.pid;

http {
    client_body_temp_path /tmp/client_body;
    proxy_temp_path /tmp/proxy;
    include /etc/nginx/mime.types;

    server {
        listen 80;
        location /static/ { alias /app/static/; }
        location /media/  { alias /app/media/; }
        location / {
            proxy_pass http://127.0.0.1:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

Все временные пути nginx — в `/tmp/` (чтобы не было Permission denied от непривилегированного пользователя).

## Пользователь django

Непривилегированный пользователь `django` (uid=1001). Все процессы идут под ним.

## Переменные окружения

| Перемення       | Назначение                  | По умолчанию             |
|-----------------|-----------------------------|--------------------------|
| `SECRET_KEY`    | Django secret key           | `django-insecure-secret` |
| `DEBUG`         | Режим отладки               | `False`                  |
| `ENVIRONMENT`   | `production` / `development`| —                        |
| `DATABASE_URL`  | URL базы (postgres://...)   | SQLite                   |

## Artifactory / корпоративные зеркала

- PyPI: `https://art.x5.ru/artifactory/api/pypi/pypi/simple`
- Alpine: `https://art.x5.ru/artifactory/alpine-remote/v3.23/main`
- npm: `https://art.x5.ru/artifactory/api/npm/npm`
- Docker: `docker-registry.x5.ru`
