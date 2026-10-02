# The zodiac-to-dinosaur mapping. Mirrors src/dinozodiac/signs.py --
# if you change one, change the other.
#
# The old code paired `unique(all_scopes$sign)` with a vector of dinosaurs *by
# position*, so the mapping silently depended on the order the files were read.
# A named lookup can't drift like that.

dino_signs <- c(
  Aries       = "Allosaurus",
  Taurus      = "Triceratops",
  Gemini      = "Pterodactylus",
  Cancer      = "Ankylosaurus",
  Leo         = "Tyrannosaurus Rex",
  Virgo       = "Brontosaurus",
  Libra       = "Rhamphorhynchus",
  Scorpio     = "Spinosaurus",
  Sagittarius = "Velociraptor",
  Capricorn   = "Stegosaurus",
  Aquarius    = "Quetzalcatlus",
  Pisces      = "Mosasaurus"
)

#' The signs lookup table: one row per sign, sign_id 1 (Aries) to 12 (Pisces).
build_signs <- function() {
  tibble::tibble(
    sign_id   = seq_along(dino_signs),
    greekname = names(dino_signs),
    dinoname  = unname(dino_signs)
  )
}

#' Translate zodiac sign names to dinosaurs. Vectorised; unknown signs give NA.
#'
#' @examples
#' to_dino(c("Leo", "aries"))
to_dino <- function(sign) {
  unname(dino_signs[stringr::str_to_title(stringr::str_trim(sign))])
}
