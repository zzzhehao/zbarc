# Add Heatmap Annotation to a Phylogenetic Tree

Add Heatmap Annotation to a Phylogenetic Tree

## Usage

``` r
tree_annotate(
  p,
  hm_data,
  hm_layout = list(offset = 0.01, width = 0.1),
  hm_args = list(),
  palette = NULL,
  palette_mapping = NULL,
  contrast_factor = 0
)
```

## Arguments

- p:

  A `ggtree` plot object.

- hm_data:

  A `data.frame` or tibble containing annotation columns indexed by tip
  label.

- hm_layout:

  Named list specifying `offset` and `width` passed to
  [`ggtree::gheatmap()`](https://rdrr.io/pkg/ggtree/man/gheatmap.html).
  Default is `list(offset = 0.01, width = 0.1)`.

- hm_args:

  Named list. Additional styling arguments passed to
  [`ggtree::gheatmap()`](https://rdrr.io/pkg/ggtree/man/gheatmap.html).
  Default is [`list()`](https://rdrr.io/r/base/list.html).

- palette:

  Character vector of colors, or a list of character vectors for
  multiple palettes. Default is `NULL`.

- palette_mapping:

  Named vector or list mapping column names of `hm_data` to indices or
  names in `palette`. Default is `NULL`.

- contrast_factor:

  Numeric. Brightness adjustment factor passed to
  [`zhutilsr::.adjust_palette_brightness()`](https://zzzhehao.github.io/zhutilsr/reference/dot-adjust_palette_brightness.html).
  Default is `0`.

## Value

A `ggtree` plot object with the heatmap annotation layer added.

## See also

Other tree:
[`.tree_calc_offsets()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_calc_offsets.md),
[`.tree_prep_labels()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_prep_labels.md),
[`.tree_visualize_base()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_visualize_base.md),
[`read_contree_mrbayes()`](https://zzzhehao.github.io/zbarc/reference/read_contree_mrbayes.md),
[`tree_relabel()`](https://zzzhehao.github.io/zbarc/reference/tree_relabel.md),
[`tree_reroot()`](https://zzzhehao.github.io/zbarc/reference/tree_reroot.md),
[`tree_visualize()`](https://zzzhehao.github.io/zbarc/reference/tree_visualize.md)
