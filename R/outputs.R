#' Get and parse full rally template data for a either a base rally OSF id or a vector of rally OSF ids
#'
#' @param root_id root rally OSF component id
#' @param rally_ids vector of OSF component ids pointing to indivual rally spaces
#' @param force should template content be forced to be read and parsed from OSF instead of from the cache even if text content matches?
#' @param groups optional list providing information about the rally groups
#' @export
#' @examples
#' \dontrun{
#' # init_rally_engine() # one time only
#' rally_ids <- get_rally_ids()
#' groups <- get_rally_groups()
#' content <- get_rally_content(rally_ids = rally_ids, groups = groups)
#' gen_overview_data(content)
#' gen_dashboard_data(content)
#' gen_questions_data(content)
#' gen_ppt(content)
#' }
get_rally_content <- function(root_id = NULL, rally_ids = NULL, force = FALSE,
  groups = groups) {
  if (is.null(rally_ids)) {
    if (is.null(root_id)) {
      rally_ids <- get_rally_ids()
    } else {
      rally_ids <- get_rally_ids(root_id)
    }
  }
  if (is.null(rally_ids))
    stop("Must specify either root_id or rally_ids.", call. = FALSE)

  content <- parse_wikis(rally_ids, force = force, groups = groups)

  content
}

#' Get rally content directly from cache
#' @param base_path location of base path where outputs should be stored
#' @param root_id root rally OSF component id
#' @export
get_rally_content_cache <- function(base_path = get_rally_base_path(), root_id = NULL) {
  cache_path <- file.path(base_path, "cache")
  if (!dir.exists(cache_path))
    stop("No content in cache. Please run get_rally_content()")
  ff <- list.files(cache_path, pattern = "\\.rds", full.names = TRUE)
  nms <- gsub("\\.rds", "", basename(ff))
  res <- lapply(ff, readRDS)
  names(res) <- nms

  # # if new rallies have come online, we need to take care of them
  # if (is.null(root_id)) {
  #   rally_ids <- get_rally_ids()
  # } else {
  #   rally_ids <- get_rally_ids(root_id)
  # }
  # not_added <- setdiff(rally_ids, nms)
  # if (length(not_added) > 0) {
  #   res <- c(res, parse_wikis(not_added))
  # }

  res
}

#' Get rally group information
#'
#' @param root_id root rally OSF component id
#' @export
get_rally_groups <- function(root_id = "s7p4z") {
  pat <- get_osf_pat()
  config <- httr::add_headers(Authorization = sprintf("Bearer %s", pat))
  link <- paste0("https://api.osf.io/v2/nodes/", root_id, "/children/")
  call <- httr::GET(link, config)
  out <- jsonlite::fromJSON(httr::content(call, "text", encoding = "UTF-8"))

  res <- lapply(seq_along(out$data$attributes$title), function(i) {
    ttl <- out$data$attributes$title[i]
    num <- gsub("Rally ([0-9]+)\\..*", "\\1", ttl)
    nm <- trimws(gsub("Rally [0-9]+\\.(.*)", "\\1", ttl))
    id <- out$data$id[i]
    # get children
    link <- paste0("https://api.osf.io/v2/nodes/", id, "/children/")
    call <- httr::GET(link, config)
    tmp <- jsonlite::fromJSON(httr::content(call, "text", encoding = "UTF-8"))
    children <- tmp$data$id
    list(num = num, name = nm, id = id, children = children)
  })
  nums <- sapply(res, function(x) x$num)
  res[order(nums)]
}

#' Generate data for overview pages
#'
#' @param content list of rally template content obtained from \code{\link{get_rally_content}}, or a single element of this
#' @param base_path location of base path where outputs should be stored
#' @param outfile should the output be written to a JSON file? If FALSE, a JSON string will be returned instead.
#' @importFrom jsonlite toJSON
#' @export
gen_overview_data <- function(content, base_path = get_rally_base_path(), outfile = TRUE) {
  gen_single <- function(x) {
    keep <- c("number", "osf_id", "title", "background", "motivation", "focus", "timeline_nice",
      "deliverables", "participants", "data_list", "data_outcomes", "data_predictors",
      "methods", "findings", "value", "next_steps")
    x <- x[keep]
    clean <- c("deliverables", "data_predictors", "findings", "next_steps")
    for (nm in clean) {
      if (inherits(x[[nm]], "osf_bulletlist")) {
        x[[nm]] <- paste(unlist(lapply(x[[nm]],
          function(a) paste(a, collapse = "\n"))), collapse = "\n")
      } else {
        x[[nm]] <- paste(unlist(lapply(x[[nm]],
          function(a) paste(a, collapse = "\n"))), collapse = "\n\n")
      }
    }
    jsonlite::toJSON(x, auto_unbox = TRUE, pretty = TRUE)
  }

  if (inherits(content, "rally_content")) {
    out <- gen_single(content)
    if (outfile) {
      overview_path <- file.path(base_path, "overview")
      if (!dir.exists(overview_path))
        dir.create(overview_path)
      cat(out, file = paste0(overview_path, "/", content$osf_id, ".json"))
    } else {
      return(out)
    }
  } else {
    if (!outfile)
      stop("Must specify outfile = TRUE if generating overview data for multiple rallies.")
    for (x in content) {
      out <- gen_single(x)
      overview_path <- file.path(base_path, "overview")
      if (!dir.exists(overview_path))
        dir.create(overview_path)
      cat(out, file = paste0(overview_path, "/", x$osf_id, ".json"))
    }
  }
}

#' Generate dashboard page data from rally content
#'
#' @param content list of rally template content obtained from \code{\link{get_rally_content}}
#' @param base_path location of base path where outputs should be stored
#' @param outfile should the output be written to a JSON file? If FALSE, a JSON string will be returned instead.
#' @export
gen_dashboard_data <- function(content, base_path = get_rally_base_path(), outfile = TRUE) {
  res <- unname(lapply(content, function(a) {
    nms <- c("number", "osf_id", "title", "tags", "participants", "timeline", "focus",
      "presentation_id", "group")
    a <- a[intersect(names(a), nms)]
    a$rally <- gsub("([0-9]+).*", "\\1", a$number)
    a$sprint <- toupper(gsub("([0-9]+)(.*)", "\\2", a$number))
    a$tags <- paste(a$tags, collapse = ", ")
    a$osf_link <- paste0("http://osf.io/", a$osf_id)
    a$overview_link <- paste0("overview.html?id=", a$osf_id)
    a$report_link <- NULL
    if (!is.null(a$presentation_id))
      a$report_link <- paste0("ppt_final/", a$number, ".pptx")
    a
  }))

  out <- as.character(jsonlite::toJSON(res, auto_unbox = TRUE, pretty = TRUE))
  # out <- paste0("var data = ", out)

  if (outfile) {
    dashboard_path <- base_path # for now...
    if (!dir.exists(dashboard_path))
      dir.create(dashboard_path)
    cat(out, file = paste0(dashboard_path, "/rally_data.json"))
  } else {
    return (out)
  }
}

#' Generate questions page data from rally content
#'
#' @param content list of rally template content obtained from \code{\link{get_rally_content}}
#' @param base_path location of base path where outputs should be stored
#' @param outfile should the output be written to a JSON file? If FALSE, a JSON string will be returned instead.
#' @importFrom dplyr bind_rows data_frame group_by summarise
#' @export
gen_questions_data <- function(content, base_path = get_rally_base_path(), outfile = TRUE) {
  tmp <- dplyr::bind_rows(lapply(content, function(a) {
    dplyr::data_frame(
      rally_id = a$number,
      id = as.numeric(a$hbgd_question_id),
      start = a$timeline$start,
      end = a$timeline$end
    )
  }))

  aa <- tmp %>%
    dplyr::group_by(id) %>%
    dplyr::summarise(
      n_rallies = n(),
      rally_link = paste0(paste0("<a href='overview/", rally_id, "_overview.html' target='_blank'>", rally_id, "</a>"), collapse = ", "),
      end = max(end)
    )

  quests <- suppressMessages(dplyr::left_join(quests, aa))

  out <- as.character(jsonlite::toJSON(quests, auto_unbox = TRUE, pretty = TRUE))

  if (outfile) {
    questions_path <- base_path # for now...
    if (!dir.exists(questions_path))
      dir.create(questions_path)
    # out <- paste0("var data = ", out)
    cat(out, file = paste0(questions_path, "/question_data.json"))
  } else {
    return(out)
  }
}

#' Generate powerpoint slides from rally content
#'
#' @param content list of rally template content obtained from \code{\link{get_rally_content}}
#' @param base_path location of base path where outputs should be stored
#' @param force should ppt output be forced to be generated even if text content matches?
#' @param in_api Is this function being called from an API? If so, an extra message with a link will be printed.
#' @importFrom yaml yaml.load
#' @importFrom officer read_pptx layout_summary
#' @importFrom whisker whisker.render
#' @export
gen_ppt <- function(content, base_path = get_rally_base_path(), force = FALSE, in_api = FALSE) {
  for (output in content) {
    res <- try(gen_ppt_single(output, base_path = base_path, force = force, in_api = in_api))
    if (inherits(res, "try-error"))
      message(as.character(res))
    message("")
  }
}

#' Generate powerpoint slides from rally content
#'
#' @param content list of rally template content obtained from \code{\link{get_rally_content}}
#' @param base_path location of base path where outputs should be stored
#' @export
download_ppt_final <- function(content, base_path = get_rally_base_path()) {
  out_dir <- file.path(base_path, "ppt_final")
  if (!dir.exists(out_dir))
    dir.create(out_dir)

  for (ctnt in content) {
    message("Downloading final ppt presentation for ", ctnt$number, "...")
    if (!is.null(ctnt$presentation_id)) {
      fp <- file.path(out_dir, paste0(ctnt$number, ".pptx"))
      download_file(ctnt$presentation_id, fp)
    } else {
      message("... Final ppt not specified for ", ctnt$number, ".")
    }
  }
}
