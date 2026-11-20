# Load Sequences from NCBI GenBank with Metadata from INSD XML Files

Load Sequences from NCBI GenBank with Metadata from INSD XML Files

## Usage

``` r
load_insd(path, recursive = TRUE, regex = NULL)
```

## Arguments

- path:

  Character vector. Path to a directory or to XML files. If a directory
  path is provided, matching XML files are loaded.

- recursive:

  Logical. When `path` is a directory, whether to search for XML files
  recursively. Default is `TRUE`.

- regex:

  Character or `NULL`. Optional regular expression passed to `pattern`
  in [`list.files()`](https://rdrr.io/r/base/list.files.html) when
  `path` is a directory.

## Value

A `data.frame` containing parsed INSD fields plus three derived columns:

- `zbarc.voucher`:

  Specimen voucher extracted from `source_specimen_voucher` or
  `source_isolate`.

- `zbarc.organism_id`:

  Specimen identifier derived from `source_organism` and
  `zbarc.voucher`.

- `zbarc.gene`:

  Gene/locus label detected from `INSDSeq_definition` (`cytochrome`,
  `18S`, `28S`, `16S`, or fallback `INSDSeq_definition`).

## See also

Other insd:
[`.read_insd()`](https://zzzhehao.github.io/zbarc/reference/dot-read_insd.md)
