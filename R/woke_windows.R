#' Download Boston Police Department data
#' @export
#' @examples
#' \dontrun{
#'   x <- download_bpd_offenses()
#' }
#' 

download_bpd_offenses <- function() {
  options(timeout = 120)
  url <- "https://wokewindows-data.s3.amazonaws.com/boston_pd_citations_with_names_2011_2020.csv"
  dest <- tempfile(fileext = ".csv")
  download.file(url, dest)
  dest
}

#' @rdname download_bpd_offenses
#' @export
#' @examples
#' \dontrun{
#'   x <- read_bpd_offenses()
#' }
#' 

read_bpd_offenses <- function() {
  download_bpd_offenses() |>
    readr::read_csv() |>
    janitor::clean_names()
}