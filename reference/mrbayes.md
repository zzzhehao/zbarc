# Helper Functions to Generate MrBayes Blocks in NEXUS Files

Generates MrBayes command strings for inclusion in a NEXUS `MrBayes`
block. `mrbayes_mcmc_cmd()`, `mrbayes_partition_cmd()`,
`mrbayes_lset_cmd()`, `mrbayes_prset_cmd()`, and `mrbayes_sum_cmd()`
construct individual commands, while `mrbayes_block()` wraps them in a
`BEGIN MrBayes; ... END;` block. See also
[`prepare_mrbayes_nexus()`](https://zzzhehao.github.io/zbarc/reference/prepare_mrbayes_nexus.md)
for an end-to-end wrapper.

## Usage

``` r
mrbayes_mcmc_cmd(gen = 1e+07, nchains = 4, nruns = 4, stopval = 0.01, ...)

mrbayes_partition_cmd(loci_length, loci_name, protein_coding_loci)

mrbayes_lset_cmd(nst, rates, ..., applyto = NULL)

mrbayes_prset_cmd(..., applyto = NULL)

mrbayes_sum_cmd(..., cmd)

mrbayes_block(...)
```

## Arguments

- gen:

  Numeric or integer. Number of MCMC generations (`ngen`). Default is
  `10000000`.

- nchains:

  Integer. Number of MCMC chains. Default is `4`.

- nruns:

  Integer. Number of parallel runs. Default is `4`.

- stopval:

  Numeric. Convergence threshold (`stopval`) when `stoprule = "yes"`.
  Default is `0.01`.

- ...:

  Additional arguments. Must be a named list.

  `mrbayes_mcmc_cmd()`

  :   Further parameters to include in the `mcmc` command.

  `mrbayes_lset_cmd()`

  :   Further parameters to include in the `lset` command.

  `mrbayes_prset_cmd()`

  :   Further parameters to include in the `prset` command.

  `mrbayes_sum_cmd()`

  :   Further parameters to include in `sumt` or `sump`; `cmd` must also
      be provided to specify `"sumt"` or `"sump"`.

  `mrbayes_block()`

  :   Commands to include inside the `MrBayes` block.

- loci_length:

  Numeric vector. Length of each locus.

- loci_name:

  Character vector. Name of each locus.

- protein_coding_loci:

  Character vector. Names of protein-coding loci to partition further by
  codon position (`_pos1`, `_pos2`, `_pos3`).

- nst:

  Numeric or integer. Value passed to `lset nst`.

- rates:

  Character. Value passed to `lset rates`.

- applyto:

  Numeric vector or `NULL`. Partition indices to apply `lset` settings
  to. Default is `NULL` (applies to the whole alignment).

- cmd:

  Character. Either `"sump"` or `"sumt"` when `...` arguments are
  supplied.

## Value

A character string containing formatted MrBayes command(s).

## See also

[`prepare_mrbayes_nexus()`](https://zzzhehao.github.io/zbarc/reference/prepare_mrbayes_nexus.md)

Other mrbayes:
[`prepare_mrbayes_nexus()`](https://zzzhehao.github.io/zbarc/reference/prepare_mrbayes_nexus.md)
