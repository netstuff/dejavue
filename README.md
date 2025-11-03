# Dejavue
Boilerplate for fullstack web app with SSR


## Installation

### Python dependencies

```sh
uv
```

### Typescript dependencies
```sh
pnpm install
```

## Run development mode

### Django backend

```sh
uv run ./manage.py runserver
```

### Vuejs frontend

```sh
vite dev
```

Visit http://localhost:8000 to get a sample site.


## Run production mode

### Docker (WIP)

```sh
docker build -t dejavue:latest .
docker run -e 8000 dejavue:latest
```
