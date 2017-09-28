library(rallyengine)
library(future)
plan(multiprocess)

init_rally_engine()

base_path <- get_rally_base_path()

if (!dir.exists(file.path(base_path, "cache"))) {
  content <- get_rally_content()
} else {
  content <- get_rally_content_cache()
}

status <- list()

#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}

#* @serializer contentType list(type="application/json")
#* @get /rally_ids
get_rally_ids <- function(completed = TRUE, in_progress = TRUE, no_timeline = TRUE) {
  ids <- names(content)
  ends <- do.call(c, lapply(content, function(x) x$timeline$end))
  ended_flag <- ends <= as.Date(Sys.time())
  ind <- NULL
  if (completed)
    ind <- c(ind, which(ended_flag))
  if (in_progress)
    ind <- c(ind, which(!ended_flag))
  if (no_timeline)
    ind <- c(ind, which(is.na(ends)))

  ids[ind]
}

#* @serializer contentType list(type="application/json")
#* @get /questions
get_questions_data <- function() {
  content <<- get_latests(content)
  gen_questions_data(content, outfile = FALSE)
}

#* @serializer contentType list(type="application/json")
#* @get /dashboard
get_dashboard_data <- function() {
  content <<- get_latests(content)
  gen_dashboard_data(content, outfile = FALSE)
}

#* @serializer contentType list(type="application/json")
#* @get /overview
get_overview_data <- function(id) {
  if (missing(id)) {
    message("Must provide an ID for an OSF rally space.", call. = FALSE)
    return(NULL)
  }
  if (!id %in% names(content)) {
    message("The ID '", id, "' is not a valid ID of a OSF rally space.", call. = FALSE)
    return(NULL)
  }
  content <<- get_latests(content)
  gen_overview_data(content[[id]], outfile = FALSE)
}

#* @serializer contentType list(type="application/json")
#* @get /update
update_content <- function() {
  id <- substr(digest::digest(Sys.time()), 1, 6)

  tf <- tempfile()
  f <- future({
    capture.output(tmp <- get_rally_content(), type = "message", file = tf)
  })
  # f <- future({
  #   res <- 1
  #   capture.output({
  #     for (i in 1:10) {
  #       Sys.sleep(1)
  #       message(i)
  #       res <- res + 1
  #     }
  #   }, file = tf, type = "message")
  #   res
  # })
  status[[id]] <<- list(f = f, tf = tf)
  jsonlite::toJSON(id, auto_unbox = TRUE)
}

#* @get /check_update
check_update <- function(id) {
  if (missing(id)) {
    message("Must provide an ID for an update process.", call. = FALSE)
    return(NULL)
  }
  if (is.null(status[[id]])) {
    message("No update to check.")
    return(NULL)
  }
  if (!resolved(status[[id]]$f)) {
    readLines(status[[id]]$tf, warn = FALSE)
  } else {
    # for some reason we can't get the value of the future so we'll read from cache instead
    # content <<- value(status[[id]]$f)
    content <- get_rally_content_cache()
    res <- readLines(status[[id]]$tf, warn = FALSE)
    c(res, "FINISHED")
  }
}

#* @serializer contentType list(type="application/json")
#* @get /update_ppt
update_ppt <- function() {
  id <- substr(digest::digest(Sys.time()), 1, 6)

  tf <- tempfile()
  f <- future({
    capture.output(tmp <- gen_ppt(content, in_api = TRUE), type = "message", file = tf)
  })
  status[[id]] <<- list(f = f, tf = tf)
  jsonlite::toJSON(id, auto_unbox = TRUE)
}

#* @get /check_update_ppt
check_update_ppt <- function(id) {
  if (missing(id))
    stop("Must provide an ID for an update process.", call. = FALSE)
  if (is.null(status[[id]]))
    stop("No update to check.")
  if (!resolved(status[[id]]$f)) {
    readLines(status[[id]]$tf, warn = FALSE)
  } else {
    res <- readLines(status[[id]]$tf, warn = FALSE)
    c(res, "FINISHED")
  }
}




# load_all()
# library(plumber)
# r <- plumb("inst/api/api.R")
# r$run(port = 8000)

# library(plumber)
# Sys.setenv(RALLY_API_SERVER = "")
# r <- plumb(system.file("api/api.R", package = "rallyengine"))
# r$run(host = "hbghdkirallyengine.exaptive.city", port = 8000)

# export OSF_PAT=
# export RALLY_BASE_PATH=~/html
# export RALLY_API_SERVER=http://hbghdkirallyengine.exaptive.city:8000

# curl localhost:8000/questions
# curl localhost:8000/dashboard
# curl localhost:8000/overview?id=35y4a
# curl localhost:8000/update
# curl localhost:8000/check_update?id=
