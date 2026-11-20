# Visualize Base Phylogenetic Tree

Draws the base phylogenetic tree with customizable tip labels, node
support labels, root edge, rotation, and scale bar.

## Usage

``` r
.tree_visualize_base(
  tree,
  nodelab_threshold = NULL,
  tree_angle = NULL,
  ggtree_args = list(),
  tiplab_args = list(),
  nodelab_args = list(),
  rootedge = 0.02,
  y.exp = c(0.1, 0.1),
  x.exp = NULL,
  treescale_pos = c(0, -1),
  treescale_args = list()
)
```

## Arguments

- tree:

  A prepared `tidytree` `treedata` object.

- nodelab_threshold:

  Numeric or `NULL`. Threshold below or equal to which numeric node
  labels are hidden (`NA`). Default is `NULL`.

- tree_angle:

  Numeric or `NULL`. Angle in degrees to rotate the tree. Default is
  `NULL`.

- ggtree_args:

  Named list. Additional arguments passed to
  [`ggtree::ggtree()`](https://rdrr.io/pkg/ggtree/man/ggtree.html).
  Default is [`list()`](https://rdrr.io/r/base/list.html).

- tiplab_args:

  Named list. Arguments passed to
  [`ggtree::geom_tiplab()`](https://rdrr.io/pkg/ggtree/man/geom_tiplab.html).

- nodelab_args:

  Named list. Arguments passed to
  [`ggtree::geom_nodelab()`](https://rdrr.io/pkg/ggtree/man/geom_nodelab.html).

- rootedge:

  Numeric. Length of the root edge. Default is `0.02`.

- y.exp:

  Numeric vector of length 2 passed to `expand` in
  [`ggplot2::scale_y_continuous()`](https://ggplot2.tidyverse.org/reference/scale_continuous.html).
  Default is `c(0.1, 0.1)`.

- x.exp:

  Numeric vector of length 2 or `NULL`. Controls x-axis expansion when
  non-`NULL`. Default is `NULL` (uses package default behavior).

- treescale_pos:

  Numeric vector of length 2 giving `c(x, y)` coordinates for the tree
  scale. Default is `c(0, -1)`.

- treescale_args:

  Named list. Additional arguments passed to
  [`ggtree::geom_treescale()`](https://rdrr.io/pkg/ggtree/man/geom_treescale.html).
  Default is [`list()`](https://rdrr.io/r/base/list.html).

## Value

A `ggtree` plot object.

## See also

Other tree:
[`.tree_calc_offsets()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_calc_offsets.md),
[`.tree_prep_labels()`](https://zzzhehao.github.io/zbarc/reference/dot-tree_prep_labels.md),
[`read_contree_mrbayes()`](https://zzzhehao.github.io/zbarc/reference/read_contree_mrbayes.md),
[`tree_annotate()`](https://zzzhehao.github.io/zbarc/reference/tree_annotate.md),
[`tree_relabel()`](https://zzzhehao.github.io/zbarc/reference/tree_relabel.md),
[`tree_reroot()`](https://zzzhehao.github.io/zbarc/reference/tree_reroot.md),
[`tree_visualize()`](https://zzzhehao.github.io/zbarc/reference/tree_visualize.md)
