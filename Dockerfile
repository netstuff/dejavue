# Этап 1: Сборщик Python
FROM python:3.14-alpine as backend

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_SYSTEM_PYTHON=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

RUN apk update && apk add --no-cache build-base libpq-dev

COPY pyproject.toml uv.lock* ./

RUN uv pip install --system --no-cache -r pyproject.toml

# Этап 2: Сборщик frontend
FROM node:22-alpine as frontend

WORKDIR /app

COPY package.json package-lock.json tsconfig.json vite.config.ts ./
RUN npm install

COPY frontend/ frontend/
RUN npm run build

# Этап 3: Финальный образ
FROM python:3.14-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=dejavue.settings \
    PATH="/usr/local/bin:$PATH"

ENV ENVIRONMENT=production \
    DEBUG=false

WORKDIR /app

RUN apk update && apk add --no-cache supervisor nginx

RUN addgroup -g 1001 django && \
    adduser -D -u 1001 -G django django

COPY --from=backend /usr/local/lib/python3.14/site-packages /usr/local/lib/python3.14/site-packages
COPY --from=backend /usr/local/bin /usr/local/bin
COPY --from=frontend /app/staticfiles /app/staticfiles

# COPY pyproject.toml *.lock Makefile manage.py ./
# COPY dejavue/ ./
COPY . .

RUN mkdir -p /app/logs /var/lib/nginx/logs && \
    chown -R django:django /app && \
    chown -R django:django /var/log/nginx && \
    chown -R django:django /var/lib/nginx && \
    chmod -R 755 /app

USER django

RUN python manage.py migrate --no-input
RUN python manage.py collectstatic --noinput
RUN rm -rf /app/staticfiles

EXPOSE 8081

COPY deploy/nginx.conf /etc/nginx/nginx.conf
COPY deploy/supervisord.conf /etc/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
