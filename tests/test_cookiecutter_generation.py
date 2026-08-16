"""End-to-end tests for the dejavue cookiecutter template.

Every test bakes a fresh project from the template in a temporary directory
via the ``cookies`` fixture from pytest-cookies and asserts on the generated
files, following the options and hook logic defined in ``cookiecutter.json``,
``hooks/pre_gen_project.py`` and ``hooks/post_gen_project.py``.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from pathlib import Path

FRONTEND_KEEP = {
    "vue": ["frontend/main.ts", "frontend/pages/Index.vue"],
    "react": ["frontend/main.tsx", "frontend/pages/Index.tsx"],
}

FRONTEND_REMOVED = {
    "vue": ["frontend/main.tsx", "frontend/pages/Index.tsx"],
    "react": ["frontend/main.ts", "frontend/pages/Index.vue"],
}


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


# --------------------------------------------------------------------------- #
# Default generation
# --------------------------------------------------------------------------- #


def test_default_generation(cookies) -> None:
    result = cookies.bake()

    assert result.exit_code == 0, result.exception
    assert result.exception is None
    assert result.project_path.name == "my_app"
    assert (result.project_path / "manage.py").is_file()
    assert result.context["frontend"] == "auto"


# --------------------------------------------------------------------------- #
# Derived options (cookiecutter.json template values)
# --------------------------------------------------------------------------- #


@pytest.mark.parametrize(
    ("project_name", "expected_slug"),
    [
        ("My App", "my_app"),
        ("My-App", "my_app"),
        ("My.App", "my_app"),
        ("  Trimmed  ", "__trimmed__"),
        ("MyAPP", "myapp"),
    ],
)
def test_project_slug_derivation(cookies, project_name, expected_slug) -> None:
    result = cookies.bake(extra_context={"project_name": project_name})

    assert result.exit_code == 0, result.exception
    assert result.context["project_slug"] == expected_slug
    assert result.project_path.name == expected_slug


def test_author_email_derivation(cookies) -> None:
    result = cookies.bake(
        extra_context={"author_name": "Yury Andreev", "domain_name": "Example.com"},
    )

    assert result.exit_code == 0, result.exception
    assert result.context["author_email"] == "yury-andreev@example.com"


# --------------------------------------------------------------------------- #
# Rendered project files
# --------------------------------------------------------------------------- #


def test_pyproject_rendered(cookies) -> None:
    result = cookies.bake(
        extra_context={
            "project_name": "Blog",
            "description": "Test description",
            "author_name": "Jane Doe",
            "version": "1.2.3",
        },
    )

    assert result.exit_code == 0, result.exception
    pyproject = read_text(result.project_path / "pyproject.toml")
    assert 'name = "blog"' in pyproject
    assert 'version = "1.2.3"' in pyproject
    assert 'description = "Test description"' in pyproject
    assert 'name = "Jane Doe", email = "jane-doe@example.com"' in pyproject


def test_settings_rendered(cookies) -> None:
    result = cookies.bake(
        extra_context={
            "project_name": "Blog",
            "language": "en",
            "timezone": "Europe/Moscow",
        },
    )

    assert result.exit_code == 0, result.exception
    settings = read_text(result.project_path / "blog" / "settings.py")
    assert "'blog'," in settings
    assert "ROOT_URLCONF = 'blog.urls'" in settings
    assert "LANGUAGE_CODE = 'en'" in settings
    assert "TIME_ZONE = 'Europe/Moscow'" in settings


def test_views_renders_project_name(cookies) -> None:
    result = cookies.bake(extra_context={"project_name": "Blog"})

    assert result.exit_code == 0, result.exception
    views = read_text(result.project_path / "blog" / "views.py")
    assert '"name": "Blog"' in views


def test_readme_rendered(cookies) -> None:
    result = cookies.bake(extra_context={"project_name": "Blog"})

    assert result.exit_code == 0, result.exception
    readme = read_text(result.project_path / "README.md")
    assert "# Blog" in readme
    assert "cd blog" in readme


# --------------------------------------------------------------------------- #
# frontend option: file pruning in the post-gen hook
# --------------------------------------------------------------------------- #


@pytest.mark.parametrize("frontend", ["vue", "react"])
def test_frontend_files_pruned(cookies, frontend) -> None:
    result = cookies.bake(extra_context={"frontend": frontend})

    assert result.exit_code == 0, result.exception
    for rel in FRONTEND_KEEP[frontend]:
        assert (result.project_path / rel).is_file(), rel
    for rel in FRONTEND_REMOVED[frontend]:
        assert not (result.project_path / rel).exists(), rel


@pytest.mark.parametrize("frontend", ["vue", "react"])
def test_frontend_package_json(cookies, frontend) -> None:
    result = cookies.bake(extra_context={"frontend": frontend})

    assert result.exit_code == 0, result.exception
    package = json.loads(read_text(result.project_path / "package.json"))
    dependencies = package["dependencies"]
    dev_dependencies = package["devDependencies"]

    if frontend == "vue":
        assert "@inertiajs/vue3" in dependencies
        assert "primevue" in dependencies
        assert "@inertiajs/react" not in dependencies
        assert "@types/react" not in dev_dependencies
    else:
        assert "@inertiajs/react" in dependencies
        assert "react" in dependencies
        assert "@inertiajs/vue3" not in dependencies
        assert "primevue" not in dependencies
        assert "@types/react" in dev_dependencies


@pytest.mark.parametrize("frontend", ["vue", "react"])
def test_frontend_vite_config(cookies, frontend) -> None:
    result = cookies.bake(extra_context={"frontend": frontend})

    assert result.exit_code == 0, result.exception
    config = read_text(result.project_path / "vite.config.ts")

    if frontend == "vue":
        assert "vue()" in config
        assert "react()" not in config
        assert 'main.ts")' in config
    else:
        assert "react()" in config
        assert "vue()" not in config
        assert 'main.tsx")' in config


@pytest.mark.parametrize("frontend", ["vue", "react"])
def test_index_html_entry(cookies, frontend) -> None:
    result = cookies.bake(extra_context={"frontend": frontend})

    assert result.exit_code == 0, result.exception
    html = read_text(result.project_path / "my_app" / "templates" / "index.html")
    entry = "main.tsx" if frontend == "react" else "main.ts"
    assert f"vite_asset '{entry}'" in html


@pytest.mark.parametrize("frontend", ["vue", "react"])
def test_tsconfig_jsx(cookies, frontend) -> None:
    result = cookies.bake(extra_context={"frontend": frontend})

    assert result.exit_code == 0, result.exception
    tsconfig = read_text(result.project_path / "tsconfig.json")
    assert ('"jsx": "react-jsx"' in tsconfig) == (frontend == "react")


def test_frontend_auto_keeps_both_entries(cookies) -> None:
    result = cookies.bake(extra_context={"frontend": "auto"})

    assert result.exit_code == 0, result.exception
    assert (result.project_path / "frontend" / "main.ts").is_file()
    assert (result.project_path / "frontend" / "main.tsx").is_file()
    package = json.loads(read_text(result.project_path / "package.json"))
    assert "@inertiajs/vue3" not in package["dependencies"]
    assert "@inertiajs/react" not in package["dependencies"]


# --------------------------------------------------------------------------- #
# pre_gen_project.py validation
# --------------------------------------------------------------------------- #


@pytest.mark.parametrize(
    "bad_context",
    [
        {"project_slug": "1bad"},
        {"project_slug": "my app"},
        {"project_slug": "my-app"},
        {"project_slug": "MyApp"},
        {"author_name": "Bad\\Name"},
    ],
)
def test_pre_gen_rejects_invalid_context(cookies, bad_context) -> None:
    result = cookies.bake(extra_context=bad_context)

    assert result.exit_code != 0
    assert result.exception is not None
    assert result.project_path is None


def test_pre_gen_accepts_valid_slug(cookies) -> None:
    result = cookies.bake(extra_context={"project_slug": "valid_slug"})

    assert result.exit_code == 0, result.exception
    assert result.project_path.name == "valid_slug"


# --------------------------------------------------------------------------- #
# _copy_without_render
# --------------------------------------------------------------------------- #


def test_skills_are_rendered(cookies) -> None:
    result = cookies.bake(extra_context={"frontend": "vue"})

    assert result.exit_code == 0, result.exception
    common = read_text(result.project_path / "skills" / "common-tasks" / "SKILL.md")
    assert "{%" not in common
    assert "@inertiajs/vue3" in common
    assert "@inertiajs/react" not in common


def test_agents_md_is_rendered(cookies) -> None:
    result = cookies.bake(extra_context={"project_name": "Blog"})

    assert result.exit_code == 0, result.exception
    agents = read_text(result.project_path / "AGENTS.md")
    assert "{{cookiecutter.project_slug}}" not in agents
    assert "blog/" in agents


def test_manual_md_is_rendered(cookies) -> None:
    result = cookies.bake(extra_context={"project_name": "Blog"})

    assert result.exit_code == 0, result.exception
    manual = read_text(result.project_path / "docs" / "MANUAL.md")
    assert "{{cookiecutter.project_slug}}" not in manual
    assert "docker build -t blog:latest ." in manual
