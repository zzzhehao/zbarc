# Snapshot MrBayes Consensus Tree During an Active Analysis

Copies ongoing MrBayes `.p`, `.t`, and NEXUS files into a temporary
preview subfolder, strips `mcmc` commands and appends `end;` to tree
files so a consensus tree can be generated interactively without
interrupting the running MrBayes process.

## Usage

``` r
midwayTreeViz(
  assets_path,
  outgroup,
  subfolder = "",
  treeviz = T,
  xlim.factor = 1.6
)
```

## Arguments

- assets_path:

  Character. Path to the directory containing active MrBayes output
  files.

- outgroup:

  Character. Outgroup taxon label used with automatic gap detection on
  string distances to root the preview tree.

- subfolder:

  Character. Subfolder name (currently unused in path construction).
  Default is `""`.

- treeviz:

  Logical. Whether to root, rescale, and plot the consensus tree with
  `ggtree`. If `FALSE`, returns the parsed `treedata` object directly.
  Default is `TRUE`.

- xlim.factor:

  Numeric. Multiplier applied to `xmax` to expand the x-axis for tip
  labels. Default is `1.6`.

## Value

A `ggplot`/`ggtree` object if `treeviz = TRUE`, or a `tidytree`
`treedata` object if `treeviz = FALSE`.
