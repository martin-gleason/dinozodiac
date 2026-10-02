"""Dinozodiac: horoscopes, but make them dinosaurs."""

from dinozodiac.scrapers import Horoscope
from dinozodiac.signs import DINO_SIGNS, to_dino

__all__ = ["DINO_SIGNS", "Horoscope", "to_dino"]
