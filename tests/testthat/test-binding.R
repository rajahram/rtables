

test_that("cbind_rtables works", {

    x <- rtable(c("A", "B"), rrow("row 1", 1,2), rrow("row 2", 3, 4))

    y <- rtable("C", rrow("row 1", 5), rrow("row 2", 6))

    tab <- cbind_rtables(x, y)
    expect_equal(ncol(tab), 3)
    expect_equal(ncol(rtables:::tt_labelrow(tab)), 3)
    expect_equal(nrow(tab), 2)
})


test_that("cbind_rtables works with 3 tables", {

    tab1 <- rtable(
        header = "a",
        rrow("one", 1)
    )
    tab2 <- rtable(
        header = "b",
        rrow("one", 2)
    )
    tab3 <- rtable(
        header = "c",
        rrow("one", 3)
    )

    newtab <- cbind_rtables(tab1, tab2, tab3)
    expect_equal(ncol(newtab), 3)
    expect_equal(c(1, 2, 3), unlist(cell_values(newtab)))
})


test_that("cell formats not dropped when cbinding", {

    tab1 <- rtable(
        header = "a",
        rrow("one", rcell(1.1111111, format = "xx.x"))
    )
    tab2 <- rtable(
        header = "b",
        rrow("one", rcell(2.2222222, format = "xx.xxxx"))
    )

    cbtab <- cbind_rtables(tab1, tab2)
    expect_identical(rtables:::value_formats(tree_children(cbtab)[[1]]),
                     list("xx.x", "xx.xxxx"))
})


## unit tests for chk_cbindable_many

test_that("chk_cbindable_many works", {
    chk_cbindable_many <- rtables:::chk_cbindable_many
    tr <- rrow("", 5, 6, 7)
    expect_true(chk_cbindable_many(list(tr, tr, tr)))
    tr2 <- rrow("label")
    expect_error(chk_cbindable_many(list(tr, tr, tr2)), "Cannot cbind different types of TableRow objects together")

    tab1 <- rtable(c("col11", "col21", "col31"),
                   tr2, tr, tr)

    expect_true(chk_cbindable_many(list(tab1, tab1, tab1)))
    tab2 <- tab1
    top_left(tab2) <- "hiii"
    ## topleft missmatch ok if mix of empty and single non-empty value
    expect_true(chk_cbindable_many(list(tab1, tab2, tab1, tab2)))
    tab3 <- tab1
    top_left(tab3) <- "oops"
    ## topleft mismatch error on 2+ non-empty values
    expect_error(chk_cbindable_many(list(tab1, tab2, tab1, tab2, tab3)))
    tr3 <- rrow("rowlabel", 5, 6, 7)
    tr4 <- rrow("oh no!", 5, 6, 7)
    tab4 <- rtable(c("col1", "col2", "col3"),
                   tr2, tr, tr3)
    tab5 <- rtable(c("col1", "col2", "col3"),
                   tr2, tr, tr3)
    ## rowname mismatches
    expect_error(chk_bindable_many(list(tab1, tab2, tab4)))
    expect_error(chk_bindable_many(list(tab1, tab2, tab4)))
    tab6 <- rtable(c("col1", "col2", "col3"),
                   tr2, tr2, tr)
    ## row class mismatch
    expect_error(chck_bindable_many(list(tab, tab2, tab6)))
})

test_that("c/rbind and top-left behave", {
    lyt <- basic_table() %>%
        append_topleft("Hi") %>%
        analyze("AGE", mean)
    tab <- build_table(lyt, DM)

    tab2 <- tab
    top_left(tab2) <- "oh no!"
    mat_form <- matrix_form(tab)
    expect_identical(mat_form$strings[1,1], top_left(tab))
    mat_form2 <- matrix_form(tab2)
    expect_identical(mat_form2$strings[1,1], top_left(tab2))
    ## might be redundant in light of chk_cbindable_many unit tests above
    ## but its not hurting anything so just leave it
    expect_error(cbind_rtables(tab, tab2))
    expect_error(rbind(tab, tab2))
})
