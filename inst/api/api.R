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
#* @get /update
update_content <- function() {
  id <- substr(digest::digest(Sys.time()), 1, 6)

  tf <- tempfile()
  # f <- future({
  #   capture.output(get_rally_content(), type = "message", file = tf)
  # })
  f <- future({
    res <- 1
    capture.output({
      for (i in 1:10) {
        Sys.sleep(1)
        message(i)
        res <- res + 1
      }
    }, file = tf, type = "message")
    res
  })
  status[[id]] <<- list(f = f, tf = tf)
  jsonlite::toJSON(id, auto_unbox = TRUE)
}

#* @get /check_update
check_update <- function(id) {
  if (missing(id))
    stop("Must provide an ID for an update process.", call. = FALSE)
  if (is.null(status[[id]]))
    stop("No update to check.")
  if (!resolved(status[[id]]$f)) {
    readLines(status[[id]]$tf, warn = FALSE)
  } else {
    # content <<- value(f)
    res <- readLines(status[[id]]$tf, warn = FALSE)
    c(res, "FINISHED")
  }
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
  if (missing(id))
    stop("Must provide an ID for an OSF rally space.", call. = FALSE)
  if (!id %in% names(content))
    stop("The ID '", id, "' is not a valid ID of a OSF rally space.", call. = FALSE)
  content <<- get_latests(content)
  gen_overview_data(content[[id]], outfile = FALSE)
}

# load_all()
# library(plumber)
# # r <- plumb("inst/api/api.R")
# r <- plumb(system.file("api/api.R", package = "rallyengine"))
# r$run(port=8000)

# curl localhost:8000/questions
# curl localhost:8000/dashboard
# curl localhost:8000/overview?id=35y4a
# curl localhost:8000/update
# curl localhost:8000/check_update?id=
