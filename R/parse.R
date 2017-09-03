get_rally_ids <- function(base_id = "s7p4z", pat = get_osf_pat()) {
  config <- httr::add_headers(Authorization = sprintf("Bearer %s", pat))
  link <- paste0("https://api.osf.io/v2/nodes/", base_id, "/children/")
  call <- httr::GET(link, config)
  res <- jsonlite::fromJSON(httr::content(call, "text", encoding = "UTF-8"))
  rally_links <- unname(unlist(res$data$relationships$children))
  unlist(lapply(rally_links, function(link) {
    call <- httr::GET(link, config)
    res <- jsonlite::fromJSON(httr::content(call, "text", encoding = "UTF-8"))
    res$data$id
  }))
}

get_wiki_content <- function(id, pat = get_osf_pat()) {
  config <- httr::add_headers(Authorization = sprintf("Bearer %s", pat))

  # first get latest wiki id
  link <- paste0("https://api.osf.io/v2/nodes/", id, "/wikis/")
  call <- httr::GET(link, config)
  res <- jsonlite::fromJSON(httr::content(call, "text", encoding = "UTF-8"))
  tmp <- subset(res$data$attributes, name == "home")$path
  wiki_id <- gsub("/", "", tmp)

  # now get wiki content
  link <- paste0("https://api.osf.io/v2/wikis/", wiki_id, "/content")
  call <- httr::GET(link, config)
  res <- ""
  if (call$status == 200)
    res <- httr::content(call, "text", encoding = "UTF-8")
  res
}

get_section_meta <- function(cur_txt) {
  meta <- cur_txt[grepl("^`\\[", cur_txt)]
  meta_nms <- gsub("^`\\[([a-z]+).*", "\\1", meta)
  meta <- lapply(meta, function(x) {
    gsub("`\\[[a-z]+: (.*)]`$", "\\1", x)
  })
  names(meta) <- meta_nms
  for (nm in c("description", "assignee", "due", "id", "required", "content"))
    if (is.null(meta[[nm]]))
      meta[[nm]] <- ""

  meta
}

trim_blank_lines <- function(x) {
  n <- length(x)
  front <- 0
  while (front < n && x[front + 1] == "")
    front <- front + 1
  back <- n + 1
  while (back > 1 && x[back - 1] == "")
    back <- back - 1
  if ((front + 1) > (back - 1)) {
    keep_idx <- 1
  } else {
    keep_idx <- (front + 1):(back - 1)
  }
  x <- x[keep_idx]
  x
}

get_sections <- function(txt) {
  txt <- strsplit(txt, "\n")[[1]]

  id_idx <- which(grepl("^`\\[id", txt))

  ids <- gsub("`\\[id: (.*)\\].*", "\\1", txt[id_idx])

  sec_beg <- (id_idx)
  sec_end <- c(id_idx[-1] - 1, length(txt))

  content <- lapply(seq_along(id_idx), function(ii) {
    cur_txt <- txt[sec_beg[ii]:sec_end[ii]]
    meta <- get_section_meta(cur_txt)
    cur_txt <- cur_txt[!grepl("^`\\[", cur_txt)]
    cur_txt <- cur_txt[!grepl("^## ", cur_txt)]
    cur_txt <- gsub("\\\r", "", cur_txt)
    cur_txt <- trim_blank_lines(cur_txt)
    list(meta = meta, content = cur_txt)
  })

  names(content) <- ids

  content
}

fixme <- function(...) {
  x <- paste0(...)
  class(x) <- c(class(x), "fixme")
  x
}

remove_braces <- function(x) gsub("\\{|\\}", "", x)
trim <- function(x) gsub("^\\s+|\\s+$", "", x)

expect_not_blank <- function(x) {
  if (inherits(x$content, "fixme"))
    return (x)
  if (length(x$content) == 0 || x$content == "")
    x$content <- fixme("Section with id: ", x$meta$id, " does not contain any content.")
  x
}

expect_num_lines <- function(x, n) {
  if (inherits(x$content, "fixme"))
    return (x)
  if (length(x$content) != n)
    x$content <- fixme("Section with id: ", x$meta$id, " should have ", n,
      " line", ifelse(n == 1, "", "s"), " of content. ",
      "Found ", length(x$content), " lines:\n", paste(x$content, collapse = "\n"))
  x
}

expect_osf_link <- function(x) {
  if (nchar(x$content) != 5)
    x$content <- fixme("Section with id: ", x$meta$id, " should be a valid OSF ID which should have 5 alphanumeric characters. Found ", nchar(x$content), " characters:\n", paste(x$content, collapse = "\n"))
  x
}

expect_yes_no <- function(x) {
  x$content <- tolower(x$content)
  x$content <- remove_braces(x$content)
  if (!x$content %in% c("yes", "no"))
    x$content <- fixme("Section with id: ", x$meta$id, " should be either 'yes' or 'no'. Found: ", x$content)
  x
}

# break into subsections based on contiguous text
# there should be subsection headers but not necessary
# each subsection is either text, bulletlist, figure, or table

get_figure_table <- function(txt, type = "figure", pat = get_osf_pat()) {
  res <- list(type = type)
  ttl_idx <- which(grepl("Title:", txt))
  if (length(ttl_idx) > 0)
    res$title <- gsub(".*Title:(.*)", "\\1", txt[ttl_idx]) %>%
      trim() %>%
      remove_braces()
  cpt_idx <- which(grepl("Caption:", txt))
  if (length(cpt_idx) > 0)
    res$caption <- gsub(".*Caption:(.*)", "\\1", txt[cpt_idx]) %>%
      trim() %>%
      remove_braces()
  lnk_idx <- which(grepl("Link:", txt))
  if (length(lnk_idx) > 0) {
    res$link <- gsub(".*Link:(.*)", "\\1", txt[lnk_idx]) %>%
      trim() %>%
      remove_braces()
    if (grepl("^https://osf.io", res$link)) {
      item_id <- gsub("https://osf.io/(.*)/", "\\1", res$link)
      message("  - reading ", type, ": '", res$link, "' from OSF...")
      config <- httr::add_headers(Authorization = sprintf("Bearer %s", pat))
      link <- paste0("https://api.osf.io/v2/guids/", item_id)
      call <- httr::GET(link, config)
      if (call$status_code != 200) {
        # TODO: need to error about how file not found
      }
      cdat <- jsonlite::fromJSON(httr::content(call, "text", encoding = "UTF-8"))
      fname <- cdat$data$attributes$name
      fcontent <- httr::GET(cdat$data$links$download, config,
        httr::write_memory())
      res$base64 <- base64enc::base64encode(httr::content(fcontent))
      res$ext <- tools::file_ext(fname)
    } else {
      # TODO: need to error about how the figure link isn't valid
    }
  } else {
    # TODO: need to error about how there isn't a link to the figure
  }

  # TEMPORARY: to work offline without OSF (and more quickly)
  # lnk2_idx <- which(grepl("Link2:", txt))
  # if (length(lnk2_idx) > 0) {
  #   res$link2 <- gsub(".*Link2:(.*)", "\\1", txt[lnk2_idx]) %>%
  #     trim() %>%
  #     remove_braces()
  #   fcontent <- readBin(res$link2, what = "raw", n = 1e6)
  #   res$base64 <- base64enc::base64encode(fcontent)
  #   res$ext <- tools::file_ext(res$link2)
  # }
  class(res) <- c("list", paste0("osf_", type))
  res
}

parse_detail_section <- function(x, multi = TRUE) {
  sec_idx <- which(grepl("^#### ", x$content))
  if (! 1 %in% sec_idx)
    sec_idx <- c(1, sec_idx)
  sec_beg <- sec_idx
  sec_end <- c(sec_idx[-1] - 1, length(x$content))

  x$content <- lapply(seq_along(sec_idx), function(ii) {
    cur_txt <- x$content[sec_beg[ii]:sec_end[ii]]
    header <- ""
    if (grepl("^#### ", cur_txt[1])) {
      header <- gsub("^#### ", "", cur_txt[1])
      cur_txt <- cur_txt[-1]
    }

    cur_txt <- trim_blank_lines(cur_txt)

    ssec_beg <- which(cur_txt == "")
    if (! 1 %in% ssec_beg)
      ssec_beg <- c(1, ssec_beg)
    ssec_end <- c(ssec_beg[-1] - 1, length(cur_txt))
    if (length(ssec_beg) != 1) {
      rm_idx <- which(ssec_beg == ssec_end)
      if (length(rm_idx) > 0) {
        ssec_beg <- ssec_beg[-rm_idx]
        ssec_end <- ssec_end[-rm_idx]
      }
    }

    sec_ctnt <- lapply(seq_along(ssec_beg), function(jj) {
      ccur_txt <- cur_txt[ssec_beg[jj]:ssec_end[jj]]
      ccur_txt <- trim_blank_lines(ccur_txt)

      is_bullet_list <- all(grepl("^(\\+|\\-|\\*)", trim(ccur_txt)))
      is_figure <- grepl("^Figure:", ccur_txt[1])
      is_table <- grepl("^Table:", ccur_txt[1])
      if (is_bullet_list) {
        res <- ccur_txt
        class(res) <- c("character", "osf_bulletlist")
      } else if (is_figure) {
        res <- get_figure_table(ccur_txt, "figure")
      } else if (is_table) {
        res <- get_figure_table(ccur_txt, "table")
      } else {
        res <- ccur_txt
        class(res) <- c("character", "osf_text")
      }

      res
    })
    if (!multi)
      return (sec_ctnt[[1]])

    list(header = header, content = sec_ctnt)
  })

  if (!multi)
    x$content <- x$content[[1]]

  x
}

get_type <- function(x) {
  tmp <- x$meta$content
  tmp <- gsub("`\\[content_type\\: (.*)\\]`\\\r", "\\1", tmp)
  # strsplit(tmp, " or ")[[1]]
  tmp
}

get_id <- function(x) {
  tmp <- x$meta$id
  gsub("`\\[id\\: (.*)\\]`\\\r", "\\1", tmp)
}

get_required <- function(x) {
  tmp <- x$meta$required
  tmp <- gsub("`\\[required\\: (.*)\\]`\\\r", "\\1", tmp)
  ifelse(tmp == "true", TRUE, FALSE)
}

get_data_meta <- function(x) {
  x$content <- lapply(x$content, function(a) {
    idx <- which(rallyengine::studies$study_id == a)
    if (length(idx) == 1) {
      return(as.list(rallyengine::studies[idx,]))
    } else {
      # TODO: error if data not found...
    }
  })
  x
}

#' @importFrom parsedate parse_date
parse_entry <- function(x) {
  id <- get_id(x)
  type <- get_type(x)
  req <- get_required(x)
  if (req)
    x <- expect_not_blank(x)

  ## validate types
  if (type == "single line") {
    x <- expect_num_lines(x, 1)
    if (inherits(x$content, "fixme")) return(x)
  } else if (type == "OSF ID") {
    x <- expect_num_lines(x, 1)
    if (x$content == "") {
      x$content <- NA
    } else {
      x <- expect_osf_link(x)
    }
    if (inherits(x$content, "fixme")) return(x)
    x
  } else if (type == "comma separated") {
    x <- expect_num_lines(x, 1)
    if (inherits(x$content, "fixme")) return(x)
    tags <- strsplit(x$content, ",")[[1]]
    tags <- trim(tags)
    x$content <- tags
  } else if (type == "start and end dates") {
    x <- expect_num_lines(x, 2)
    if (inherits(x$content, "fixme")) return(x)
    x$content <- remove_braces(x$content)
    start <- trim(gsub(".*Start:(.*)", "\\1", x$content[1]))
    end <- trim(gsub(".*End:(.*)", "\\1", x$content[2]))
    x$content <- list(
      start = as.Date(parsedate::parse_date(start)),
      end = as.Date(parsedate::parse_date(end))
    )
  } else if (type == "yes/no") {
    x <- expect_num_lines(x, 1)
    x <- expect_yes_no(x)
    if (inherits(x$content, "fixme")) return(x)
  } else if (type == "participant list") {
    x$content <- remove_braces(x$content)
    x$content <- gsub("^\\- +", "", x$content)
    valid_part <- TRUE
    res <- lapply(x$content, function(a) {
      res <- as.list(trim(strsplit(a, ",")[[1]]))
      if (length(res) != 4) {
        valid_part <<- FALSE
      } else {
        names(res) <- c("name", "affiliation", "email", "role")
      }
      res
    })
    if (valid_part) {
      x$content <- res
    } else {
      x$content <- fixme("Section with id: participants must have a line for each participant with values 'name', 'affiliation', 'email', 'role' listed and separated by commas.")
    }
    x
  } else if (type %in% c("bullet list", "single paragraph", "single paragraph or bullet list")) {
    if (grepl("bullet", type)) {
      x$content <- x$content[x$content != ""]
    } else {
      if (length(x$content) > 1)
        x$content <- paste(x$content, collapse = " ")
    }
    x <- parse_detail_section(x, multi = FALSE)
  } else if (type == "sections") {
    x <- parse_detail_section(x)
  }

  if (id == "data_list")
    x <- get_data_meta(x)

  x
}

#' @importFrom digest digest
parse_wiki <- function(rally_id, force = FALSE, pat = get_osf_pat(),
  base_path = get_rally_base_path()) {

  cache_path <- file.path(base_path, "cache")

  # rally_ids <- get_rally_ids()
  txt <- get_wiki_content(rally_id, pat = pat)
  # txt <- paste(readLines(rally_id), collapse = "\n")

  if (!dir.exists(cache_path))
    dir.create(cache_path)

  cache_dig_file <- paste0(cache_path, "/", rally_id, ".txt")
  dig_file <- paste0(cache_path, "/", rally_id, ".rds")

  cur_dig <- digest::digest(txt)
  prev_dig <- if (file.exists(cache_dig_file)) readLines(cache_dig_file, warn = FALSE) else ""
  if (prev_dig == cur_dig && file.exists(dig_file) && !force) {
    message("  Note: Text contents of wiki unchanged from last run...",
      "\n    Reading from cache...",
      "\n    To force re-processing, call with force=TRUE")
    return(readRDS(dig_file))
  }

  content <- get_sections(txt)

  # lapply(content, function(x) x$meta$content)
  ct <- unname(unlist(lapply(content, get_type)))
  rq <- unname(unlist(lapply(content, get_required)))

  output <- list()
  for (nm in names(content)) {
    message("parsing '", nm, "' ...")
    output[[nm]] <- parse_entry(content[[nm]])$content
  }

  # auxilliary outputs
  output$participants_names <- ""
  if (!inherits(output$participants, "fixme"))
    output$participant_names <- paste0(sapply(output$participants,
      function(x) x$name), collapse = ", ")
  output$current_month <- format(Sys.time(), "%B")
  output$current_year <- format(Sys.time(), "%Y")
  output$tags_string <- paste(output$tags, collapse = ", ")
  output$timeline_nice <- lapply(output$timeline, function(a)
    gsub("  ", " ", format(a, "%B %e, %Y")))

  message("caching to: ", dig_file, "...")
  cat(cur_dig, file = cache_dig_file)
  # attach digest to data so that web service can check whether it needs to load updates
  attr(output, "digest") <- cur_dig
  saveRDS(output, file = dig_file)
  # jsonlite::toJSON(output, pretty = TRUE, auto_unbox = TRUE)
  output
}

parse_wikis <- function(rally_ids, force = FALSE) {
  res <- lapply(rally_ids, function(x) {
    message("---- parsing wiki for rally ID: ", x, " ----")
    parse_wiki(x, force = force)
  })
  names(res) <- rally_ids
  res
}
