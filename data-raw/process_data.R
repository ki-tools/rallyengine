studies <- readr::read_csv("data-raw/studies.csv")
devtools::use_data(studies, overwrite = TRUE)

quests <- readxl::read_xlsx("data-raw/questions.xlsx")
names(quests) <- c("id", "cat", "question", "moscow", "score", "owners")
devtools::use_data(quests, overwrite = TRUE)
