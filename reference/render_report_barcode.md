# Generate a Combined Barcoding HTML Report

Generate a Combined Barcoding HTML Report

## Usage

``` r
render_report_barcode(
  bold_jsonl,
  blast_json,
  fasta,
  metadata = NULL,
  key_col = NULL,
  aligned = TRUE,
  output_file,
  description = as.character(Sys.Date()),
  mafft_args = NULL
)
```

## Arguments

- bold_jsonl:

  Character. Path to a BOLD JSONL result file.

- blast_json:

  Character. Path to an NCBI BLAST JSON result file.

- fasta:

  Character. Path to a sequence FASTA file.

- metadata:

  Optional `data.frame` containing sequence/specimen metadata. Default
  is `NULL`.

- key_col:

  Unquoted column name in `metadata` matching sequence names. Default is
  `NULL`.

- aligned:

  Logical. If `FALSE`, aligns `fasta` via
  [`mafft()`](https://zzzhehao.github.io/zbarc/reference/mafft.md)
  before rendering. Default is `TRUE`.

- output_file:

  Character. Path where the final HTML report should be saved.

- description:

  Character. Title or description of the run. Default is
  `as.character(Sys.Date())`.

- mafft_args:

  Character vector or `NULL`. Additional arguments passed to
  [`mafft()`](https://zzzhehao.github.io/zbarc/reference/mafft.md) when
  `aligned = FALSE`. Default is `NULL`.

## Value

Invisibly returns the normalized path to the generated HTML file.

## See also

Other report:
[`render_report()`](https://zzzhehao.github.io/zbarc/reference/render_report.md)
