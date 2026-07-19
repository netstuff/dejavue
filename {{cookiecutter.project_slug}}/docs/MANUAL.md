# Инструкция по использованию

Инструкция по подготовке окружения и дальнейшему использованию шаблона.

## Настройка окружения

### Системные требования
- Python 3.14+
- Node.js 22+
- Docker

### Установка зависимостей
```sh
make install
```

### Запуск приложения в режиме разработки
```sh
make dev
```

### Запуск приложения в режиме продакшн
```sh
docker build -t {{cookiecutter.project_slug}}:latest .
docker run -p 80:8081 {{cookiecutter.project_slug}}:latest
```
