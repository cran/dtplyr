test_that("missing values in input are missing in output", {
  dt <- lazy_dt(tibble(x = c(NA, "a b")), "DT")
  step <- separate(dt, x, c("x", "y"))
  out <- collect(step)
  expect_equal(
    show_query(step),
    expr(copy(DT)[, `:=`(!!c("x", "y"), tstrsplit(x, split = "[^[:alnum:]]+"))])
  )
  expect_equal(out$x, c(NA, "a"))
  expect_equal(out$y, c(NA, "b"))
})

test_that("convert produces integers etc", {
  dt <- lazy_dt(tibble(x = "1-1.5-FALSE"), "DT")
  step <- separate(dt, x, c("x", "y", "z"), "-", convert = TRUE)
  out <- collect(step)
  expect_equal(
    show_query(step),
    expr(copy(DT)[, `:=`(!!c("x", "y", "z"), tstrsplit(x, split = "-", type.convert = TRUE))])
  )
  expect_equal(out$x, 1L)
  expect_equal(out$y, 1.5)
  expect_equal(out$z, FALSE)
})

test_that("overwrites existing columns", {
  dt <- lazy_dt(tibble(x = "a:b"), "DT")
  step <- dt %>% separate(x, c("x", "y"))
  out <- collect(step)

  expect_equal(
    show_query(step),
    expr(copy(DT)[, `:=`(!!c("x", "y"), tstrsplit(x, split = "[^[:alnum:]]+"))])
  )
  expect_equal(step$vars, c("x", "y"))
  expect_equal(out$x, "a")
})

test_that("drops NA columns", {
  dt <- lazy_dt(tibble(x = c(NA, "a-b", "c-d")), "DT")
  step <- separate(dt, x, c(NA, "y"), "-")
  out <- collect(step)
  expect_equal(step$vars, "y")
  expect_equal(out$y, c(NA, "b", "d"))
})

test_that("checks type of `into` and `sep`", {
  dt <- lazy_dt(tibble(x = "a:b"), "DT")
  expect_snapshot(
    separate(dt, x, "x", FALSE),
    error = TRUE
  )
  expect_snapshot(
    separate(dt, x, FALSE),
    error = TRUE
  )
})

test_that("only copies when necessary", {
  dt <- tibble(x = paste(letters[1:3], letters[1:3], sep = "-"), y = 1:3) %>%
    lazy_dt("DT")
  step <- dt %>%
    filter(y < 4) %>%
    separate(x, into = c("left", "right"), sep = "-")
  expect_equal(
    show_query(step),
    expr(DT[y < 4][, `:=`(!!c("left", "right"), tstrsplit(x, split = "-"))][, `:=`("x", NULL)])
  )
})

test_that("can pass quosure to `col` arg, #359", {
  dt <- lazy_dt(tibble(combined = c("a_b", "a_b")), "DT")
  separate2 <- function(df, col, into) {
    collect(separate(df, {{ col }}, into))
  }
  out <- separate2(dt, combined, into = c("a", "b"))
  expect_named(out, c("a", "b"))
  expect_equal(out$a, c("a", "a"))
  expect_equal(out$b, c("b", "b"))
})

test_that("can use numeric `col` arg", {
  dt <- lazy_dt(tibble(combined = c("a_b", "a_b")), "DT")

  out <- collect(separate(dt, 1, into = c("a", "b")))
  expect_named(out, c("a", "b"))
  expect_equal(out$a, c("a", "a"))
  expect_equal(out$b, c("b", "b"))
})

test_that("errors on multiple columns in `col`", {
  dt <- lazy_dt(tibble(x = c("a_b", "a_b"), y = x), "DT")

  expect_error(separate(dt, c(x, y), into = c("left", "right")),
               "must select exactly one column")
})
