# Read MrBayes Output Consensus Tree

Read MrBayes Output Consensus Tree

## Usage

``` r
read_contree_mrbayes(assets_path)
```

## Arguments

- assets_path:

  Character. Path to a `.con.tre` file or a folder containing a single
  `.con.tre` file.

## Value

A `tidytree` `treedata` object read via
[`treeio::read.mrbayes()`](https://rdrr.io/pkg/treeio/man/beast-parser.html).

## See also

Other tree:
[`.tree_calc_offsets()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_calc_offsets.md),
[`.tree_prep_labels()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_prep_labels.md),
[`.tree_visualize_base()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_visualize_base.md),
[`tree_annotate()`](https://zzzhehao.github.io/zbarc/reference/tree_annotate.md),
[`tree_relabel()`](https://zzzhehao.github.io/zbarc/reference/tree_relabel.md),
[`tree_reroot()`](https://zzzhehao.github.io/zbarc/reference/tree_reroot.md),
[`tree_visualize()`](https://zzzhehao.github.io/zbarc/reference/tree_visualize.md)
