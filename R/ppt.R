# library(officer)
# library(magrittr)

#' @importFrom officer add_slide ph_empty_at slide_summary fp_text ph_add_par ph_add_text ph_with_img_at
#' @importFrom base64enc base64decode
#' @importFrom png readPNG
#' @importFrom utils tail
add_title_slide <- function(ppt, ct) {
  ppt <- officer::add_slide(ppt, "Title Slide - Text Only", "BMGF_HBGDki_Rally")

  ppt <- officer::ph_empty_at(ppt, left = 0.53, top = 2.62, height = 0.4, width = 12.13)
  id <- utils::tail(officer::slide_summary(ppt)$id, 1)
  ppt <- ppt %>%
    officer::ph_add_par(id_chr = id, type = "body") %>%
    officer::ph_add_text(str = ct$sec1, type = "body", id_chr = id,
      style = officer::fp_text(font.size = 23, bold = TRUE))

  ppt <- officer::ph_empty_at(ppt, left = 0.53, top = 3.07, height = 1.54, width = 12.13)
  id <- utils::tail(officer::slide_summary(ppt)$id, 1)
  ppt <- ppt %>%
    officer::ph_add_par(id_chr = id, type = "body") %>%
    officer::ph_add_text(str = ct$sec2, type = "body", id_chr = id,
      style = officer::fp_text(font.size = 37.3, bold = TRUE, color = "#27739a"))

  ppt <- officer::ph_empty_at(ppt, left = 0.53, top = 4.71, height = 2, width = 12.13)
  id <- utils::tail(officer::slide_summary(ppt)$id, 1)
  ppt <- ppt %>%
    officer::ph_add_par(id_chr = id, type = "body") %>%
    officer::ph_add_text(str = ct$sec3, type = "body", id_chr = id,
      style = officer::fp_text(font.size = 23, bold = FALSE))

  ppt
}

add_paragraph_slide <- function(ppt, dct, hd) {
  message(hd)
  ppt <- officer::add_slide(ppt, "Full Width Head + Copy - Text Only", "BMGF_HBGDki_Rally") %>%
    officer::ph_with_text(type = "title", hd)
  # ppt <- add_slide(ppt, "Title and Content", master = "Office Theme") %>%
  #   ph_with_text(type = "title", hd)
  ppt <- officer::ph_empty(ppt, type = "body")
  for(txt in dct) {
    blt <- gsub("( *(\\*|\\-|\\+) ).*", "\\1", txt)
    level <- 0
    if (blt != txt) {
      level <- nchar(blt) / 2
      txt <- gsub("( *(\\*|\\-|\\+) )(.*)", "\\3", txt)
    }
    ppt <- ppt %>%
      officer::ph_add_par(level = level, type = "body") %>%
      officer::ph_add_text(str = txt, type = "body")
  }
  ppt
}

add_fig_tbl_slide <- function(ppt, dct, hd) {
  type <- "Figure"
  cur_num <- fig_num
  if (inherits(dct, "osf_table")) {
    type <- "Table"
    cur_num <- tbl_num
    tbl_num <- tbl_num + 1
  } else if (inherits(dct, "osf_figure")) {
    fig_num <- fig_num + 1
  }

  f <- tempfile(fileext = paste0(".", dct$ext))
  writeBin(base64enc::base64decode(dct$base64), f)
  dims <- attr(png::readPNG(f), "dim")[1:2] / 72

  asp <- dims[1] / dims[2]
  # if figure aspect ratio is > 0.7, place the caption to the right of the plot
  # otherwise place it underneath
  mlt <- 5 / dims[1]
  fig_left <- (12.5 - dims[2]) / 2
  fig_top <- 1.5
  cap_left <- fig_left
  cap_top <- 6.6
  cap_height <- 0.5
  cap_width <- dims[2] * mlt
  if (asp > 0.7) {
    mlt <- 5.4 / dims[1]
    fig_left <- 0.5
    fig_top <- 1.5
    cap_left <- 0.6 + dims[2] * mlt
    cap_top <- 1.5
    cap_height <- 5.4
    cap_width <- 12.4 - dims[2] * mlt
  }

  capt_txt <- dct$title
  if (!is.null(dct$caption)) {
    dct$caption <- gsub("\\\\n", "\\\n", dct$caption)
    capt_txt <- paste0(capt_txt, "\n", dct$caption)
  }
  capt <- paste0(type, " ", cur_num, ". ", capt_txt)

  ppt <- officer::add_slide(ppt, "Full Width Head + Copy - Text Only", "BMGF_HBGDki_Rally") %>%
    officer::ph_with_text(type = "title", hd)
  # ppt <- add_slide(ppt, "Title Only", master = "Office Theme") %>%
  #   ph_with_text(type = "title", hd)
  ppt <- officer::ph_with_img_at(ppt, f, left = fig_left, top = fig_top,
    width = dims[2] * mlt, height = dims[1] * mlt)
  nxt_id <- as.character(max(as.integer(slide_summary(ppt)$id)) + 1)
  ppt <- officer::ph_empty_at(ppt, left = cap_left, top = cap_top,
    height = cap_height, width = cap_width, template_type = "body")
  ppt <- officer::ph_add_par(ppt, level = 1, id_chr = nxt_id, type = "body")
  ppt <- officer::ph_add_text(ppt, str = capt, id_chr = nxt_id, type = "body",
    style = officer::fp_text(bold = FALSE, font.size = 18.7))

  ppt
}
