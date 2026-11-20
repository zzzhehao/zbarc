# Run Substitution Model Selection (ModelFinder) in IQ-TREE

Copies a FASTA alignment into a dedicated run subdirectory, generates a
shell script, and executes IQ-TREE with `-m MF` to test substitution
models.

## Usage

``` r
test_sub_model(
  fasta_path,
  run_name,
  output_folder,
  iqtree_exe =
    "/Users/hu_zhehao/Desktop/utils/biology-tools/iqtree-2.3.6-macOS-arm/bin/iqtree2"
)
```

## Arguments

- fasta_path:

  Character. Path to the input FASTA alignment file.

- run_name:

  Character. Run label used to create the subdirectory and output
  prefix.

- output_folder:

  Character. Base parent folder where `run_name` will be created.

- iqtree_exe:

  Character. Path to the IQ-TREE executable.

## Value

Character path to the created run output directory
(`file.path(output_folder, run_name)`).

## See also

Other alignment:
[`check_polish()`](https://zzzhehao.github.io/zbarc/reference/check_polish.md),
[`codon_summary()`](https://zzzhehao.github.io/zbarc/reference/codon_summary.md),
[`concatenate_alignment()`](https://zzzhehao.github.io/zbarc/reference/concatenate_alignment.md),
[`gblocks()`](https://zzzhehao.github.io/zbarc/reference/gblocks.md),
[`mafft()`](https://zzzhehao.github.io/zbarc/reference/mafft.md),
[`polish_alignment()`](https://zzzhehao.github.io/zbarc/reference/polish_alignment.md),
[`split_concat_alignment()`](https://zzzhehao.github.io/zbarc/reference/split_concat_alignment.md),
[`summarize_alignment()`](https://zzzhehao.github.io/zbarc/reference/summarize_alignment.md),
[`trim_empty_columns()`](https://zzzhehao.github.io/zbarc/reference/trim_empty_columns.md)
