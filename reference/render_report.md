# Generate an Interactive HTML Report Using Quarto

Generate an Interactive HTML Report Using Quarto

## Usage

``` r
render_report(
  input,
  output_file,
  report_type = c("ncbi", "bold", "distance"),
  description
)
```

## Arguments

- input:

  Character vector. Path(s) to input file(s) passed to the Quarto
  template's `input` parameter.

- output_file:

  Character. Path where the final HTML report should be saved.

- report_type:

  Character. Type of report to render: `"ncbi"`
  (`ncbi_blast_report.qmd`), `"bold"` (`bold_barcodeid_report.qmd`), or
  `"distance"` (`genetic_distance_report.qmd`).

- description:

  Character. Title or run description passed to the Quarto template.
  Defaults to `as.character(Sys.Date())` when omitted.

## Value

Invisibly returns the normalized path to the generated HTML file.

## See also

Other report:
[`render_report_barcode()`](https://zzzhehao.github.io/zbarc/reference/render_report_barcode.md)
