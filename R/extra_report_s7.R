# Internal S7 class defining a pluggable additional report tabset
.barcoding_extra_report <- S7::new_class(
  "barcoding_extra_report",
  properties = list(
    title = S7::class_character,
    data = S7::new_S3_class("data.frame"),
    col_key = S7::class_character,
    col_overview = S7::class_character,
    render_fn = S7::class_function
  ),
  validator = function(self) {
    if (length(self@title) != 1 || !nzchar(self@title)) {
      return("`title` must be a single non-empty character string.")
    }
    if (length(self@col_key) != 1 || !nzchar(self@col_key)) {
      return("`col_key` must be a single non-empty character string.")
    }
    if (!self@col_key %in% names(self@data)) {
      return(sprintf("`col_key` ('%s') was not found in `data`.", self@col_key))
    }
    missing_ov <- setdiff(self@col_overview, names(self@data))
    if (length(missing_ov) > 0) {
      return(sprintf(
        "`col_overview` column(s) not found in `data`: %s",
        paste(missing_ov, collapse = ", ")
      ))
    }
    NULL
  }
)

#' Create an Additional Report Specification for Combined Barcoding Reports
#'
#' @param title Character. Tabset title in the combined HTML report.
#' @param data `data.frame` or `tibble` containing the report data.
#' @param col_key Character. Column name in `data` matched against sequence names (`query_id`).
#' @param col_overview Character vector. Column names in `data` to include in Overview & Metadata.
#' @param render_fn Optional function `function(df, theme)` returning a `reactable` or `htmltools` UI.
#'
#' @return An internal `barcoding_extra_report` S7 object.
#' @export
extra_report_spec <- function(
    title,
    data,
    col_key,
    col_overview = character(0),
    render_fn = NULL
) {
  if (is.null(render_fn)) {
    render_fn <- function(df, theme) {
      reactable::reactable(
        df,
        theme = theme,
        highlight = TRUE,
        striped = TRUE,
        sortable = TRUE,
        filterable = TRUE,
        compact = TRUE,
        defaultPageSize = 50,
        style = list(fontSize = "13px")
      )
    }
  }

  .barcoding_extra_report(
    title = title,
    data = as.data.frame(data),
    col_key = col_key,
    col_overview = col_overview,
    render_fn = render_fn
  )
}