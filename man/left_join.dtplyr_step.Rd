% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/step-join.R
\name{left_join.dtplyr_step}
\alias{left_join.dtplyr_step}
\title{Join data tables}
\usage{
\method{left_join}{dtplyr_step}(x, y, ..., by = NULL, copy = FALSE, suffix = c(".x", ".y"))
}
\arguments{
\item{x, y}{A pair of \code{\link[=lazy_dt]{lazy_dt()}}s.}

\item{...}{Other parameters passed onto methods.}

\item{by}{A join specification created with \code{\link[dplyr:join_by]{join_by()}}, or a character
vector of variables to join by.

If \code{NULL}, the default, \verb{*_join()} will perform a natural join, using all
variables in common across \code{x} and \code{y}. A message lists the variables so
that you can check they're correct; suppress the message by supplying \code{by}
explicitly.

To join on different variables between \code{x} and \code{y}, use a \code{\link[dplyr:join_by]{join_by()}}
specification. For example, \code{join_by(a == b)} will match \code{x$a} to \code{y$b}.

To join by multiple variables, use a \code{\link[dplyr:join_by]{join_by()}} specification with
multiple expressions. For example, \code{join_by(a == b, c == d)} will match
\code{x$a} to \code{y$b} and \code{x$c} to \code{y$d}. If the column names are the same between
\code{x} and \code{y}, you can shorten this by listing only the variable names, like
\code{join_by(a, c)}.

\code{\link[dplyr:join_by]{join_by()}} can also be used to perform inequality, rolling, and overlap
joins. See the documentation at \link[dplyr:join_by]{?join_by} for details on
these types of joins.

For simple equality joins, you can alternatively specify a character vector
of variable names to join by. For example, \code{by = c("a", "b")} joins \code{x$a}
to \code{y$a} and \code{x$b} to \code{y$b}. If variable names differ between \code{x} and \code{y},
use a named character vector like \code{by = c("x_a" = "y_a", "x_b" = "y_b")}.

To perform a cross-join, generating all combinations of \code{x} and \code{y}, see
\code{\link[dplyr:cross_join]{cross_join()}}.}

\item{copy}{If \code{x} and \code{y} are not from the same data source,
and \code{copy} is \code{TRUE}, then \code{y} will be copied into the
same src as \code{x}.  This allows you to join tables across srcs, but
it is a potentially expensive operation so you must opt into it.}

\item{suffix}{If there are non-joined duplicate variables in \code{x} and
\code{y}, these suffixes will be added to the output to disambiguate them.
Should be a character vector of length 2.}
}
\description{
These are methods for the dplyr generics \code{\link[=left_join]{left_join()}}, \code{\link[=right_join]{right_join()}},
\code{\link[=inner_join]{inner_join()}}, \code{\link[=full_join]{full_join()}}, \code{\link[=anti_join]{anti_join()}}, and \code{\link[=semi_join]{semi_join()}}. Left, right,
inner, and anti join are translated to the \verb{[.data.table} equivalent,
full joins to \code{\link[data.table:merge]{data.table::merge.data.table()}}.
Left, right, and full joins are in some cases followed by calls to
\code{\link[data.table:setcolorder]{data.table::setcolorder()}} and \code{\link[data.table:setattr]{data.table::setnames()}} to ensure that column
order and names match dplyr conventions.
Semi-joins don't have a direct data.table equivalent.
}
\examples{
library(dplyr, warn.conflicts = FALSE)

band_dt <- lazy_dt(dplyr::band_members)
instrument_dt <- lazy_dt(dplyr::band_instruments)

band_dt \%>\% left_join(instrument_dt)
band_dt \%>\% right_join(instrument_dt)
band_dt \%>\% inner_join(instrument_dt)
band_dt \%>\% full_join(instrument_dt)

band_dt \%>\% semi_join(instrument_dt)
band_dt \%>\% anti_join(instrument_dt)
}
