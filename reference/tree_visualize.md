# Visualize a Phylogenetic Tree with Optional Heatmap Annotation

Visualize a Phylogenetic Tree with Optional Heatmap Annotation

## Usage

``` r
tree_visualize(
  tree,
  hm_data = NULL,
  format.taxa = FALSE,
  parse = FALSE,
  nodelab_threshold = NULL,
  hm_layout = list(offset = 0.01, width = 0.1, label_margin = 0.02),
  hm_args = list(),
  base_args = list(tiplab_args = list(size = 3, align = TRUE), nodelab_args = list(size =
    3, nudge_x = 0.001, nudge_y = 0, hjust = 0), ggtree_args = list(size = 0.5), y.exp =
    c(0.01, 0.01)),
  palette = NULL,
  palette_mapping = NULL,
  contrast_factor = 0
)
```

## Arguments

- tree:

  A `tidytree` `treedata` object.

- hm_data:

  Optional `data.frame` for heatmap annotation. If `NULL`, no heatmap is
  drawn.

- format.taxa:

  Logical. Whether taxa names should be formatted for plotmath. Default
  is `FALSE`.

- parse:

  Logical. Whether tip labels should be parsed as plotmath expressions.
  Default is `FALSE`.

- nodelab_threshold:

  Numeric or `NULL`. Hide numeric node labels less than or equal to this
  value.

- hm_layout:

  Named list of heatmap layout parameters (`offset`, `width`,
  `label_margin`).

- hm_args:

  Named list of styling arguments passed to
  [`tree_annotate()`](https://zzzhehao.github.io/zbarc/reference/tree_annotate.md).

- base_args:

  Named list of rendering arguments passed to
  [`.tree_visualize_base()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_visualize_base.md).

- palette:

  Character vector or list of color vectors for heatmap annotations.
  Default is `NULL`.

- palette_mapping:

  Named vector or list mapping annotation columns to palettes. Default
  is `NULL`.

- contrast_factor:

  Numeric. Brightness adjustment factor passed to
  [`tree_annotate()`](https://zzzhehao.github.io/zbarc/reference/tree_annotate.md).
  Default is `0`.

## Value

A `ggtree` plot object.

## See also

Other tree:
[`.tree_calc_offsets()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_calc_offsets.md),
[`.tree_prep_labels()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_prep_labels.md),
[`.tree_visualize_base()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_visualize_base.md),
[`read_contree_mrbayes()`](https://zzzhehao.github.io/zbarc/reference/read_contree_mrbayes.md),
[`tree_annotate()`](https://zzzhehao.github.io/zbarc/reference/tree_annotate.md),
[`tree_relabel()`](https://zzzhehao.github.io/zbarc/reference/tree_relabel.md),
[`tree_reroot()`](https://zzzhehao.github.io/zbarc/reference/tree_reroot.md)
