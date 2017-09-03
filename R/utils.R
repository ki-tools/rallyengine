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

#' Ensure environment is set up (one-time only)
#' @export
init_rally_engine <- function() {
  message("Checking OSF_PAT environment variable...")
  get_osf_pat()
  message("Checking RALLY_BASE_PATH environment variable...")
  base_path <- get_rally_base_path()
  message("Copying files...")
  copy_dir(
    from = system.file("www", package = "rallyengine"),
    to = base_path
  )
  cat("", file = file.path(base_path, ".initialized"))

  message("You are good to go!")
  invisible(NULL)
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
