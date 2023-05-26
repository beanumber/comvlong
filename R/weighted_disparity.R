globalVariables(
  c("officer_id", "location_name", "event_date", "disparity",
    "n", "p_0", "alpha", "n_sim", "p_sim", "disparity_sim",
    "is_my_officer", "race", "cites_0", "n_0", "cites", 
    "disparity_wgt_sim", "p_hat")
)

#' Weighted disparity measures for police officers
#' @param citations \code{\link{data.frame}} of police citations
#' @param my_officer_id identifier for the officer in question
#' @param race_of_interest race of defendant. Default is \code{BLACK}
#' @param ... current ignored
#' @export
#' @examples
#' compare_officer_citations(comvlong::boston_pd_1120, 9047)
compare_officer_citations <- function(
    citations = comvlong::boston_pd_1120,
    my_officer_id = 9047, ...) {
  my_officer_summary <- citations |>
    dplyr::filter(officer_id == my_officer_id) |>
    dplyr::group_by(location_name) |>
    dplyr::summarize(
      num_citations = dplyr::n(),
      begin_date = min(event_date),
      end_date = max(event_date)
    )

  citations |>
    dplyr::filter(
      event_date >= min(my_officer_summary$begin_date),
      event_date <= max(my_officer_summary$end_date),
      location_name %in% my_officer_summary$location_name
    )
}

#' @rdname compare_officer_citations
#' @export
#' @examples
#' summarize_officer_citations(comvlong::boston_pd_1120, 9047)
summarize_officer_citations <- function(
    citations = comvlong::boston_pd_1120, 
    my_officer_id = 9047, 
    race_of_interest = "BLACK"
) {
  compare_officer_citations(citations, my_officer_id) |>
    dplyr::mutate(
      is_my_officer = ifelse(is.na(officer_id), FALSE, 
                             officer_id == my_officer_id)
    ) |>
    dplyr::group_by(location_name) |>
    dplyr::summarize(
      n_0 = sum(!is_my_officer),
      n = sum(is_my_officer),
      cites_0 = sum((race == race_of_interest) & !is_my_officer, na.rm = TRUE),
      cites = sum((race == race_of_interest) & is_my_officer, na.rm = TRUE),
      p_0 = cites_0 / n_0,
      p_hat = cites / n
    ) |>
    dplyr::filter(n_0 > 0, n > 0) |>
    dplyr::mutate(
      # weight
      alpha = n / sum(n),
      disparity = alpha * (p_hat - p_0)
    )
}

#' @rdname compare_officer_citations
#' @param n_sims Number of simulations
#' @export
#' @examples
#' simulate_officer_citations(comvlong::boston_pd_1120, 9047)
simulate_officer_citations <- function(
    citations = comvlong::boston_pd_1120, 
    my_officer_id = 9047, 
    race_of_interest = "BLACK", 
    n_sims = 100
) {
  x <- summarize_officer_citations(citations, my_officer_id)
  sims <- x |>
    dplyr::select(n, p_0, alpha) |>
    dplyr::mutate(
      n_sim = purrr::map2(n, p_0, ~ stats::rbinom(n = n_sims, size = .x, prob = .y))
    ) |>
    tidyr::unnest(cols = n_sim) |>
    dplyr::mutate(
      replicate = rep(1:n_sims, times = nrow(x)),
      p_sim = n_sim / n,
      disparity_sim = p_sim - p_0
    )

  sims |>
    dplyr::group_by(replicate) |>
    dplyr::summarize(
      disparity_wgt_sim = sum(alpha * disparity_sim)
    )
}

#' @rdname compare_officer_citations
#' @export
#' @examples
#' observe_officer(comvlong::boston_pd_1120, 9047, race_of_interest = "BLACK")
#' observe_officer(comvlong::boston_pd_1120, 9047, race_of_interest = "WHITE")
observe_officer <- function(
    citations = comvlong::boston_pd_1120, 
    my_officer_id = 9047, 
    race_of_interest = "BLACK"
) {
  summarize_officer_citations(citations, my_officer_id, race_of_interest) |>
    dplyr::pull(disparity) |>
    sum()
}


#' @rdname compare_officer_citations
#' @param data A \code{\link{data.frame}} of draws from the bootstrap distribution
#' @param y_hat The observed weighted disparity
#' @export
#' @examples
#' sims <- simulate_officer_citations()
#' y_hat <- observe_officer()
#' p_value_officer(sims, y_hat)
p_value_officer <- function(data, y_hat, tail_direction = "right") {
  data |>
    infer::get_p_value(y_hat, direction = tail_direction)
}

#' @rdname compare_officer_citations
#' @export
#' @examples
#' sims <- simulate_officer_citations(n_sims = 10000)
#' y_hat <- observe_officer()
#' visualize_weighted_disparity(sims, y_hat)
visualize_weighted_disparity <- function(data, y_hat) {
  attr(data, "type") <- "bootstrap"
  data |>
    dplyr::mutate(stat = disparity_wgt_sim) |>
    infer::visualize() +
    infer::shade_p_value(obs_stat = y_hat, direction = "two-sided")
}
