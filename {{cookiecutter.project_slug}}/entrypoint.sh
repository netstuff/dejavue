#!/bin/sh
# Entrypoint для Django-проекта: ожидает БД (если PostgreSQL),
# применяет миграции, собирает статику и запускает основной процесс
# (по умолчанию supervisord → gunicorn + nginx).

set -e

echo "==> Django entrypoint: starting..."

# Создаём runtime-директории для статики и медиа
mkdir -p /app/static /app/media

# Ожидание PostgreSQL, если указан DATABASE_URL (в противном случае SQLite)
if [ -n "${DATABASE_URL}" ] && echo "${DATABASE_URL}" | grep -q '^postgres'; then
    echo "==> Waiting for PostgreSQL..."
    python - <<'PYEOF'
import os
import re
import socket
import time

url = os.environ.get("DATABASE_URL", "")
match = re.match(r"^postgres(?:ql)?://[^:/@]+:[^:/@]+@([^:/@]+):(\d+)/", url)
host, port = (match.group(1), int(match.group(2))) if match else ("db", 5432)

deadline = time.monotonic() + 60
while time.monotonic() < deadline:
    try:
        with socket.create_connection((host, port), timeout=2):
            break
    except OSError:
        time.sleep(1)
else:
    raise SystemExit(f"PostgreSQL at {host}:{port} is not reachable")
PYEOF
fi

# Применяем миграции базы данных
echo "==> Applying database migrations..."
python manage.py migrate --noinput

# Собираем статические файлы в STATIC_ROOT (/app/static)
echo "==> Collecting static files..."
python manage.py collectstatic --noinput

# Передаём управление основному процессу (CMD, по умолчанию supervisord)
echo "==> Executing: $*"
exec "$@"
