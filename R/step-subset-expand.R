#' Expand data frame to include all possible combinations of values.
#'
#' @description
#' This is a method for the tidyr `expand()` generic. It is translated to
#' [data.table::CJ()].
#'
#' @param ... Specification of columns to expand. Columns can be atomic vectors
#'   or lists.
#'
#'   * To find all unique combinations of `x`, `y` and `z`, including those not
#'     present in the data, supply each variable as a separate argument:
#'     `expand(df, x, y, z)`.
#'   * To find only the combinations that occur in the
#'     data, use `nesting`: `expand(df, nesting(x, y, z))`.
#'   * You can combine the two forms. For example,
#'     `expand(df, nesting(school_id, student_id), date)` would produce
#'     a row for each present school-student combination for all possible
#'     dates.
#'
#'   Unlike the data.frame method, this method does not use the full set of
#'   levels, just those that appear in the data.
#'
#'   When used with continuous variables, you may need to fill in values
#'   that do not appear in the data: to do so use expressions like
#'   `year = 2010:2020` or `year = full_seq(year,1)`.
#' @param data A [lazy_dt()].
#' @inheritParams tidyr::expand
#' @examples
#' library(tidyr)
#'
#' fruits <- lazy_dt(tibble(
#'   type   = c("apple", "orange", "apple", "orange", "orange", "orange"),
#'   year   = c(2010, 2010, 2012, 2010, 2010, 2012),
#'   size  =  factor(
#'     c("XS", "S",  "M", "S", "S", "M"),
#'     levels = c("XS", "S", "M", "L")
#'   ),
#'   weights = rnorm(6, as.numeric(size) + 2)
#' ))
#'
#' # All possible combinations ---------------------------------------
#' # Note that only present levels of the factor variable `size` are retained.
#' fruits %>% expand(type)
#' fruits %>% expand(type, size)
#'
#' # This is different from the data frame behaviour:
#' fruits %>% dplyr::collect() %>% expand(type, size)
#'
#' # Other uses -------------------------------------------------------
#' fruits %>% expand(type, size, 2010:2012)
#'
#' # Use `anti_join()` to determine which observations are missing
#' all <- fruits %>% expand(type, size, year)
#' all
#' all %>% dplyr::anti_join(fruits)
#'
#' # Use with `right_join()` to fill in missing rows
#' fruits %>% dplyr::right_join(all)
# exported onLoad
expand.dtplyr_step <- function(data, ..., .name_repair = "check_unique") {
  dots <- capture_dots(data, ..., .j = FALSE)
  dots <- dots[!map_lgl(dots, is_null)]
  if (length(dots) == 0) {
    return(data)
  }

  named_dots <- have_name(dots)
  if (any(!named_dots)) {
    # Auto-names generated by enquos() don't always work with the CJ() step
      ## Ex: `1:3`
    # Replicates the "V" naming convention data.table uses
    symbol_dots <- map_lgl(dots, is_symbol)
    needs_v_name <- !symbol_dots & !named_dots
    v_names <- paste0("V", 1:length(dots))
    names(dots)[needs_v_name] <- v_names[needs_v_name]
    names(dots)[symbol_dots] <- lapply(dots[symbol_dots], as_name)
  }
  names(dots) <- vctrs::vec_as_names(names(dots), repair = .name_repair)
  dots_names <- names(dots)

  out <- step_subset_j(
    data,
    vars = union(data$groups, dots_names),
    j = expr(CJ(!!!dots, unique = TRUE))
  )

  # Delete duplicate columns if group vars are expanded
  if (any(dots_names %in% out$groups)) {
    group_vars <- out$groups
    expanded_group_vars <- dots_names[dots_names %in% group_vars]

    out <- step_subset(
      out, groups = character(), j = expr(!!expanded_group_vars := NULL)
    )
    out <- group_by(out, !!!syms(group_vars))
  }

  out
}
