"""Dejavue base views."""

from dataclasses import dataclass, asdict

from inertia import render


@dataclass
class GalleryPicture:
    url: str
    title: str
    title_en: str
    description: str
    wiki_link: str


def index(request):
    """Index page with simple SPA."""
    return render(request, "Index", props={"name": "Dejavue"})


def gallery(request):
    """Simple SPA gallery on separate page."""
    pictures = [
        GalleryPicture(
            url="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Russo-Balt_С24_55_ralli_monte-karlo_1911-1912.jpg/500px-Russo-Balt_С24_55_ralli_monte-karlo_1911-1912.jpg",
            title="Руссо-Балт",
            title_en="Russo-Balt",
            description="A first russian automobile (1912).",
            wiki_link="https://en.wikipedia.org/wiki/Russo-Balt",
        ),
        GalleryPicture(
            url="https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Novik%28EM%291.jpg/2880px-Novik%28EM%291.jpg",
            title="Новик",
            title_en="Novice",
            description="One of the best destroyers (1915).",
            wiki_link="https://en.wikipedia.org/wiki/Russian_destroyer_Novik",
        ),
        GalleryPicture(
            url="https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Sikorsky_Ilya_Muromets_S-27_E_%28Yeh-2%29_bomber_%2819759078469%29.jpg/960px-Sikorsky_Ilya_Muromets_S-27_E_%28Yeh-2%29_bomber_%2819759078469%29.jpg",
            title="Илья Муромец",
            title_en="Ilya Murometz",
            description="The only one in the world (at the time of the First World War) heavy bambardier.",
            wiki_link="https://ru.wikipedia.org/wiki/Илья_Муромец_(самолёт)",
        ),
    ]

    return render(request, "Gallery", props={
        "pictures": list(map(asdict, pictures)),
    })
