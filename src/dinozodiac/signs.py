"""The zodiac-to-dinosaur mapping. This is the single source of truth.

The R side keeps a copy in R/signs.R. If you change one, change the other.
"""

# Dicts keep insertion order, so this order is also the sign_id order (1-12).
DINO_SIGNS: dict[str, str] = {
    "Aries": "Allosaurus",
    "Taurus": "Triceratops",
    "Gemini": "Pterodactylus",
    "Cancer": "Ankylosaurus",
    "Leo": "Tyrannosaurus Rex",
    "Virgo": "Brontosaurus",
    "Libra": "Rhamphorhynchus",
    "Scorpio": "Spinosaurus",
    "Sagittarius": "Velociraptor",
    "Capricorn": "Stegosaurus",
    "Aquarius": "Quetzalcatlus",
    "Pisces": "Mosasaurus",
}


def to_dino(sign: str) -> str:
    """Return the dinosaur for a zodiac sign, ignoring case and whitespace.

    >>> to_dino(" leo ")
    'Tyrannosaurus Rex'
    """
    key = sign.strip().title()
    try:
        return DINO_SIGNS[key]
    except KeyError:
        raise ValueError(f"Unknown zodiac sign: {sign!r}") from None


def sign_id(sign: str) -> int:
    """Return the 1-based sign_id used in the database (Aries = 1)."""
    key = sign.strip().title()
    names = list(DINO_SIGNS)
    if key not in names:
        raise ValueError(f"Unknown zodiac sign: {sign!r}")
    return names.index(key) + 1
