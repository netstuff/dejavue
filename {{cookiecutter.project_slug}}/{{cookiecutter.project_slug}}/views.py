"""{{cookiecutter.project_slug}} base views."""

from dataclasses import dataclass, asdict

from django.db import connection
from django.db.migrations.loader import MigrationLoader
from django.db.migrations.recorder import MigrationRecorder
from django.http import HttpResponse, JsonResponse
from inertia import render


def healthcheck(request):
    """Healthcheck endpoint."""
    return HttpResponse("ok")


def liveness(request):
    """Liveness probe: process is up and can respond."""
    return JsonResponse({"status": "alive"})


def readiness(request):
    """Readiness probe: process can serve traffic (DB reachable, migrations applied)."""
    try:
        connection.ensure_connection()
        recorder = MigrationRecorder.Migration.objects
        applied = set(recorder.values_list('app', 'name'))
        loader = MigrationLoader(connection)
        pending = [
            key for key in loader.graph.leaf_nodes()
            if key not in applied
        ]
        if pending:
            return JsonResponse(
                {"status": "not_ready", "error": f"pending migrations: {pending}"},
                status=503,
            )
    except Exception as exc:
        return JsonResponse({"status": "not_ready", "error": str(exc)}, status=503)
    return JsonResponse({"status": "ready"})


def index(request):
    """Index page with simple SPA."""
    return render(request, "Index", props={"name": "{{cookiecutter.project_name}}"})
