---
name: testing-django-vue
description: Testing strategy — pytest + pytest-django for backend (models, views, Inertia responses), Vitest + @vue/test-utils for frontend, test file structure, fixtures, what to prioritize.
---

# Стратегия тестирования

## Python (Django)

Фреймворк: **pytest** + `pytest-django`

```makefile
test:     uv run pytest tests -n 2 --quiet
coverage: uv run pytest tests --cov -n auto --quiet
```

Структура:

```
tests/
  conftest.py           # Фикстуры (client, user, db)
  test_models.py        # Тесты моделей
  test_views.py         # Тесты вьюх
  inertia/              # Тесты Inertia-страниц
    test_dashboard.py
```

### Фикстуры

```python
@pytest.fixture
def client():
    return Client()

@pytest.fixture
def user(db, django_user_model):
    return django_user_model.objects.create_user(username='test', password='test')
```

### Тестирование Inertia-вьюх

```python
from inertia.test import InertiaResponse

def test_dashboard_returns_inertia_page(client):
    response = client.get(reverse('dashboard'))
    assert response.status_code == 200
    inertia = InertiaResponse(response)
    assert inertia.component == 'Dashboard'
    assert 'stats' in inertia.props
```

### Тестирование моделей

```python
def test_post_creation(db):
    post = Post.objects.create(title='Test', body='Body')
    assert str(post) == 'Test'
```

## Frontend (Vue)

Фреймворк: **Vitest** + `@vue/test-utils` + `happy-dom`

```bash
npm install -D vitest @vue/test-utils happy-dom
```

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [vue(), tailwindcss()],
  test: { environment: 'happy-dom' },
})
```

Структура:

```
frontend/__tests__/
  components/Counter.spec.ts
  pages/Index.spec.ts
```

## Что тестировать в первую очередь

1. Модели — `__str__`, валидация, кастомные методы
2. Вьюхи — правильный Inertia-компонент и пропсы
3. Мутации — POST/PUT/DELETE редиректят и меняют БД
4. Формы — ошибки валидации пробрасываются в Inertia-ответ
5. Авторизация — анонимов редиректит на логин
6. Граничные случаи — пустой список, 404, неверные параметры
