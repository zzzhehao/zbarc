# Write MRCA Priors into a NEXUS Alignment File for BEAST2

Appends a `BEGIN sets;` block defining `taxset` monophyly constraints to
a NEXUS file so they can be loaded into BEAUti and BEAST2 (e.g., to
constrain outgroups for ultrametric trees).

## Usage

``` r
beast2_write_mrca(nexus, monophyly_groups)
```

## Arguments

- nexus:

  Character. Path to the target NEXUS alignment file.

- monophyly_groups:

  List of lists, where each element specifies one monophyly group:

  `name`

  :   Character string of length 1 naming the `taxset`.

  `labels`

  :   Character vector of taxon labels matching those in the alignment.

## Value

Invisibly returns the result of
[`write()`](https://rdrr.io/r/base/write.html).
