# Этап 1: Сборщик Python
FROM python:3.11-slim as backend

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_SYSTEM_PYTHON=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml uv.lock* ./

RUN uv pip install --system --no-cache -r pyproject.toml

# Этап 2: Сборщик frontend
FROM node:22-slim as frontend
RUN corepack enable pnpm

WORKDIR /app

COPY package.json pnpm-lock.yaml tsconfig.json vite.config.ts ./
RUN pnpm install --dangerously-allow-all-builds

COPY frontend/ frontend/
RUN pnpm run build

# Этап 3: Финальный образ
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=dejavue.settings \
    PATH="/usr/local/bin:$PATH"

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends supervisor nginx

RUN rm -rf /var/lib/apt/lists/*

RUN addgroup --system django && \
    adduser --system --group django

COPY --from=backend /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=backend /usr/local/bin /usr/local/bin
COPY --from=frontend /app/staticfiles /app/staticfiles

# COPY pyproject.toml *.lock Makefile manage.py ./
# COPY dejavue/ ./
COPY . .

RUN mkdir /app/logs && \
    chown -R django:django /app && \
    chmod -R 755 /app

# USER django

# FIXME: REMOVE
# RUN apt-get install -y iputils-ping
# CMD ["ping", "8.8.8.8"]

RUN python manage.py migrate --no-input
RUN python manage.py collectstatic --noinput
RUN rm -rf /app/staticfiles

EXPOSE 80

COPY deploy/nginx.conf /etc/nginx/nginx.conf
COPY deploy/supervisord.conf /etc/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
