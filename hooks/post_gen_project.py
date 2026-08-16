import os

from pathlib import Path
from typing import cast, Literal


FrontendAppType = Literal["vue", "react"]


def setup_frontend(app_type: FrontendAppType):
    frontend_dir = Path("frontend")

    if app_type == "vue":
        _remove_file(frontend_dir / "main.tsx")
        _remove_file(frontend_dir / "pages" / "Index.tsx")
    elif app_type == "react":
        _remove_file(frontend_dir / "main.ts")
        _remove_file(frontend_dir / "pages" / "Index.vue")

    os.system("npm install")


def _remove_file(path: Path):
    if path.exists():
        path.unlink()


def main():  # noqa: C901, PLR0912, PLR0915
    setup_frontend(cast(FrontendAppType, "{{ cookiecutter.frontend }}"))


if __name__ == "__main__":
    main()
