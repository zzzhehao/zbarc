# Trim Conserved Alignment Blocks with Gblocks

User-facing wrapper for Gblocks that executes alignment trimming,
renames Gblocks' default output file cleanly (e.g., `_gb.fasta`), and
returns the output file path.

## Usage

``` r
gblocks(
  input,
  output = NULL,
  t = "d",
  b1 = "min",
  b2 = "min",
  b3 = 20,
  b4 = 2,
  b5 = "a",
  args = NULL,
  exec = "Gblocks",
  browse = TRUE
)
```

## Arguments

- input:

  Character. Path to the input FASTA file.

- output:

  Character or `NULL`. Custom path for the trimmed FASTA file. If `NULL`
  (default), inserts `_gb` before the file extension.

- t:

  Character. Sequence type: `"d"` (DNA), `"p"` (Protein), or `"c"`
  (Codons). Default is `"d"`.

- b1:

  Numeric or `"min"`. Minimum number of sequences for a conserved
  position. When `"min"`, calculated as `ceiling(n_seq / 2) + 1`.
  Default is `"min"`.

- b2:

  Numeric or `"min"`. Minimum number of sequences for a flank position.
  When `"min"`, equals `b1`. Default is `"min"`.

- b3:

  Integer. Maximum number of contiguous non-conserved positions. Default
  is `20`.

- b4:

  Integer. Minimum block length. Default is `2`.

- b5:

  Character. Allowed gap positions: `"a"` (All), `"h"` (Half), or `"n"`
  (None). Default is `"a"`.

- args:

  Character vector or `NULL`. Additional CLI arguments passed to
  Gblocks. Default is `NULL`.

- exec:

  Character. Path or command for the Gblocks executable. Default is
  `"Gblocks"`.

- browse:

  Logical. If `TRUE`, opens the generated HTML visualization in a
  browser. Default is `TRUE`.

## Value

Character path to the trimmed FASTA alignment file.

## See also

Other alignment:
[`check_polish()`](https://zzzhehao.github.io/zbarc/reference/check_polish.md),
[`codon_summary()`](https://zzzhehao.github.io/zbarc/reference/codon_summary.md),
[`concatenate_alignment()`](https://zzzhehao.github.io/zbarc/reference/concatenate_alignment.md),
[`mafft()`](https://zzzhehao.github.io/zbarc/reference/mafft.md),
[`polish_alignment()`](https://zzzhehao.github.io/zbarc/reference/polish_alignment.md),
[`split_concat_alignment()`](https://zzzhehao.github.io/zbarc/reference/split_concat_alignment.md),
[`summarize_alignment()`](https://zzzhehao.github.io/zbarc/reference/summarize_alignment.md),
[`test_sub_model()`](https://zzzhehao.github.io/zbarc/reference/test_sub_model.md),
[`trim_empty_columns()`](https://zzzhehao.github.io/zbarc/reference/trim_empty_columns.md)
