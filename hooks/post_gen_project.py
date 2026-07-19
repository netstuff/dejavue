import os

from pathlib import Path
from typing import Literal


ExistingAppType = Literal["vue", "react", "svelte"]


def update_existing_app(path: str, app_type: ExistingAppType):
    existing_app = Path(path)
    if not existing_app.exists():
        raise FileNotFoundError(f"Existing app not found: {path}")
    match app_type:
        case "vue":
            raise NotImplementedError("Coming soon")
        case "react":
            raise NotImplementedError("React app type is not yet supported (use only Vue)")
        case "svelte":
            raise NotImplementedError("Svelte app type is not yet supported (use only Vue)")


def setup_frontend(frontend: str):
    if existing_path := "{{ cookiecutter.existing_frontend }}":
        update_existing_app(existing_path, frontend)

    os.system("npm install")


def main():  # noqa: C901, PLR0912, PLR0915
    setup_frontend("{{ cookiecutter.frontend }}")


if __name__ == "__main__":
    main()
