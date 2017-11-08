#' Retrieve OSF personal access token environment variable OSF_PAT
#' @export
get_osf_pat <- function() {
  pat <- Sys.getenv("OSF_PAT")
  if (pat == "")
    stop("You must have an environment variable set: OSF_PAT\n",
      "that provides an OSF personal access token.", call. = FALSE)
  invisible(pat)
}

#' Retrieve rally base path environment variable RALLY_BASE_PATH
#' @export
get_rally_base_path <- function() {
  rally_base <- Sys.getenv("RALLY_BASE_PATH")
  if (rally_base == "")
    stop("You must have an environment variable set: RALLY_BASE_PATH\n",
      "that points to the base directory to use for rally outputs.", call. = FALSE)
  rally_base
}

#' Open master wikis in web browser for a given set of rally OSF ids
#'
#' @param rally_ids vector of OSF component ids pointing to indivual rally spaces
#' @param edit should the pages be opened in edit view?
#' @importFrom utils browseURL
#' @export
browse_templates <- function(rally_ids, edit = TRUE) {
  urls <- paste0("https://osf.io/", rally_ids, "/wiki/home/")
  if (edit)
    urls <- paste0(urls, "?edit&menu")
  sapply(urls, browseURL)
}

#' Get latest rally data from cache (compared to supplied input object)
#' @param obj an element of the list returned from \code{\link{get_rally_content}}
#' @export
get_latest <- function(obj) {
  cur_dig <- attr(obj, "digest")
  dig_file <- file.path(get_rally_base_path(), "cache", paste0(obj$osf_id, ".txt"))
  obj_file <- file.path(get_rally_base_path(), "cache", paste0(obj$osf_id, ".rds"))
  saved_dig <- readLines(dig_file, warn = FALSE)
  if (saved_dig != cur_dig)
    obj <- readRDS(obj_file)
  obj
}

#' Get latest rally data from cache (compared to supplied input objects)
#' @param objs a list of rally output objects obtained from \code{\link{get_rally_content}}
#' @export
get_latests <- function(objs) {
  for (ii in seq_along(objs))
    objs[[ii]] <- get_latest(objs[[ii]])
  objs
}

#' Ensure environment is set up (one-time only)
#' @param server optional specification of API server address
#' @export
init_rally_engine <- function(server = Sys.getenv("RALLY_API_SERVER")) {
  message("Checking OSF_PAT environment variable...")
  get_osf_pat()
  message("Checking RALLY_BASE_PATH environment variable...")
  base_path <- get_rally_base_path()
  message("Copying files...")
  copy_dir(
    from = system.file("www", package = "rallyengine"),
    to = base_path
  )
  if (!is.null(server) && server != "" && is.character(server))
    cat(paste0("window.RALLY_API_SERVER = '", server, "';"),
      file = file.path(base_path, "config.js"))
  cat("", file = file.path(base_path, ".initialized"))

  message("You are good to go!")
  invisible(NULL)
}

#' Download file from OSF
#' @param id OSF ID of file.
#' @param dest destination to place downloaded file.
#' @param pat pat OSF personal access token.
#' @export
download_file <- function(id, dest, pat = get_osf_pat()) {
  config <- httr::add_headers(Authorization = sprintf("Bearer %s", pat))
  link <- paste0("https://api.osf.io/v2/files/", id)
  call <- httr::GET(link, config)
  if (call$status_code == 200) {
    res <- jsonlite::fromJSON(httr::content(call, "text", encoding = "UTF-8"))
    call <- httr::GET(res$data$links$download, config,
      httr::write_disk(dest, overwrite = TRUE))
  }
  invisible(dest)
}

copy_dir <- function(from, to) {
  ff0 <- list.files(from, recursive = TRUE)
  bases <- file.path(to, setdiff(unique(dirname(ff0)), "."))
  for (bs in bases) {
    if (!dir.exists(bs))
      dir.create(bs, recursive = TRUE)
  }

  ff <- list.files(from, recursive = TRUE, full.names = TRUE)
  tf <- file.path(to, ff0)

  file.copy(ff, tf, overwrite = TRUE)
}
