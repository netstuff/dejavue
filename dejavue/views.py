"""Dejavue base views."""

from inertia import render


def index(request):
    """Index page with simple SPA."""
    return render(request, "Index", props={"name": "Dejavue"})

def gallery(request):
    """Simple SPA gallery on separate page."""
    return render(request, "Gallery", props={
        "pictures": [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Russo-Balt_С24_55_ralli_monte-karlo_1911-1912.jpg/500px-Russo-Balt_С24_55_ralli_monte-karlo_1911-1912.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Novik%28EM%291.jpg/2880px-Novik%28EM%291.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Sikorsky_Ilya_Muromets_S-27_E_%28Yeh-2%29_bomber_%2819759078469%29.jpg/960px-Sikorsky_Ilya_Muromets_S-27_E_%28Yeh-2%29_bomber_%2819759078469%29.jpg",
        ],
    })
