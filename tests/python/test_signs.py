import pytest

from dinozodiac.signs import DINO_SIGNS, sign_id, to_dino


def test_twelve_signs():
    assert len(DINO_SIGNS) == 12
    assert len(set(DINO_SIGNS.values())) == 12  # no dinosaur used twice


@pytest.mark.parametrize(
    ("sign", "dino"),
    [
        ("Aries", "Allosaurus"),
        ("leo", "Tyrannosaurus Rex"),
        ("  PISCES ", "Mosasaurus"),
    ],
)
def test_to_dino(sign, dino):
    assert to_dino(sign) == dino


def test_to_dino_rejects_unknown():
    with pytest.raises(ValueError, match="Ophiuchus"):
        to_dino("Ophiuchus")


def test_sign_id_matches_database_order():
    assert sign_id("Aries") == 1
    assert sign_id("Pisces") == 12
