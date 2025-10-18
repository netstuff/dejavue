"""Dejavue base views."""

from inertia import render


def index(request):
    return render(request, "Index", props={"name": "Dejavue"})
