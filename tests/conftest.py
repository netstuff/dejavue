"""Shared fixtures for the dejavue cookiecutter template tests."""

from __future__ import annotations

import os
import stat
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from pathlib import Path


@pytest.fixture(scope="session", autouse=True)
def stub_npm(tmp_path_factory) -> None:
    """Make the post-gen hook's ``npm install`` a no-op.

    The hook runs ``npm install`` in a subprocess, so instead of monkeypatching
    ``os.system`` we put a stub ``npm`` executable on ``PATH`` — the subprocess
    inherits the environment and resolves the stub.
    """
    bin_dir: Path = tmp_path_factory.mktemp("bin")
    npm_stub = bin_dir / "npm"
    npm_stub.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    npm_stub.chmod(npm_stub.stat().st_mode | stat.S_IEXEC)

    old_path = os.environ.get("PATH", "")
    os.environ["PATH"] = f"{bin_dir}{os.pathsep}{old_path}"

    yield

    os.environ["PATH"] = old_path
