test_that("simple calls generate expected translations", {
  dt <- lazy_dt(data.table(x = 1, y = 1, z = 1), "DT")

  expect_equal(
    dt %>% transmute(x) %>% show_query(),
    expr(DT[, .(x = x)])
  )
})

test_that("transmute generates compound expression if needed", {
  dt <- lazy_dt(data.table(x = 1, y = 2), "DT")

  expect_equal(
    dt %>% transmute(x2 = x * 2, x4 = x2 * 2) %>% show_query(),
    expr(DT[, {
      x2 <- x * 2
      x4 <- x2 * 2
      .(x2 = x2, x4 = x4)
    }])
  )
})
