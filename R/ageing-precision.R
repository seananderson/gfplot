#' Tidy PBS ageing precision data
#'
#' @param dat A data frame from \code{\link{get_ageing_precision}}
#' @param ageing_method_codes A numeric vector of ageing method codes to filter
#'   on. Defaults to codes \code{3} and \code{17}, which represent otolith
#'   'break and burn' and 'break and bake' methods.
#'
#' @export
#'
#' @family tidy data functions
#' @template ageing-precision-examples
tidy_ageing_precision <- function(dat, ageing_method_codes = c(3, 17)) {

  dbio <- filter(dat, .data$ageing_method %in% ageing_method_codes)
  # remove specimen id's for which there is no precision reading
  dbio <- group_by(dbio, specimen_id, species_code) %>%
    mutate(has_precision = 3 %in% age_reading_type_code) %>%
    filter(has_precision) %>% select(-has_precision)

  # organize dataframe with one record for each specimen id, age reading type
  # and age parameter
  dbio <- tidyr::gather(dbio, ageing_param, age, -(specimen_id:ageing_method_desc),
    -employee_id, -age_reading_id) %>%
    arrange(age_reading_id) %>%
    group_by(specimen_id, age_reading_type_code, year, species_code,
      ageing_param) %>%
    summarise(age = age[[1]], employee_id = employee_id[[1]])

  # remove bad data
  precision_aged_by_same <- group_by(dbio, specimen_id) %>%
    summarise(n_employee = length(unique(employee_id))) %>%
    filter(n_employee < 2) %>%
    dplyr::pull(specimen_id)
  dbio <- dbio %>%
    filter(!specimen_id %in% precision_aged_by_same)

  # organize data into individual columns for aging parameter + age reading type
  ageing_prec <- dbio %>%
    mutate(temp = paste(age_reading_type_code, ageing_param, sep = "_")) %>%
    reshape2::dcast(specimen_id + year + species_code ~ temp, value.var = "age")
  names(ageing_prec) <- sub("2", "prim", names(ageing_prec))
  names(ageing_prec) <- sub("3", "prec", names(ageing_prec))
  names(ageing_prec) <- sub("maximum", "max", names(ageing_prec))
  names(ageing_prec) <- sub("minimum", "min", names(ageing_prec))
  names(ageing_prec) <- sub("specimen_", "", names(ageing_prec))

  dplyr::as_tibble(ageing_prec)
}

#' Plot ageing precision data
#'
#' @param dat A properly formatted data frame, for example, from
#'   \code{\link{tidy_ageing_precision}}. Should have columns named
#'   TODO.
#' @param n Number of fish to sample if there are more fish than \code{n}.
#' @param jitter Amount to randomly jitter ages. Same jitter values are used for
#'   the precision and primary ages.
#' @param seed If a numeric value, set the random seed so that the same rows
#'   are sampled each time and the same jitter values are generated. If
#'   \code{NULL} different fish will be sampled each time function is run.
#'
#' @export
#'
#' @template ageing-precision-examples
plot_ageing_precision <- function(dat, n = 250, jitter = 0.25, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  if (n < nrow(dat))
    dat <- dplyr::sample_n(dat, size = n)
  jit <- stats::runif(nrow(dat), -jitter, jitter)
  dat$prec_age <- dat$prec_age + jit
  dat$prim_age <- dat$prim_age + jit
  ggplot(dat, aes_string("prim_age", "prec_age")) +
    geom_point(pch = 19, colour = "grey10", size = 1.2) +
    ggplot2::geom_abline(intercept = 0, slope = 1, col = "grey50", lty = 2) +
    ggplot2::geom_segment(aes_string(x = "prim_min_age", xend = "prim_max_age",
      y = "prec_age", yend = "prec_age"), alpha = 0.6) +
    ggplot2::geom_segment(aes_string(x = "prim_age", xend = "prim_age",
      y = "prec_min_age", yend = "prec_max_age"), alpha = 0.6) +
    labs(title = "Ageing Precision", x = "Primary Age", y = "Precision Age") +
    theme_pbs()
}