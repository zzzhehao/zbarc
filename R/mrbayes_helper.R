#' Helper Functions to Generate MrBayes Blocks in NEXUS Files
#' 
#' @name mrbayes
#' 
#' @description
#' Generates MrBayes command strings for inclusion in a NEXUS `MrBayes` block.
#' `mrbayes_mcmc_cmd()`, `mrbayes_partition_cmd()`, `mrbayes_lset_cmd()`, `mrbayes_prset_cmd()`,
#' and `mrbayes_sum_cmd()` construct individual commands, while `mrbayes_block()` wraps them in a
#' `BEGIN MrBayes; ... END;` block. See also [prepare_mrbayes_nexus()] for an end-to-end wrapper.
#' 
#' @return A character string containing formatted MrBayes command(s).
#' @seealso [prepare_mrbayes_nexus()]
NULL

#' @rdname mrbayes
#' @param gen Numeric or integer. Number of MCMC generations (`ngen`). Default is `10000000`.
#' @param nchains Integer. Number of MCMC chains. Default is `4`.
#' @param nruns Integer. Number of parallel runs. Default is `4`.
#' @param stopval Numeric. Convergence threshold (`stopval`) when `stoprule = "yes"`. Default is `0.01`.
#' @export
mrbayes_mcmc_cmd <- function(
    gen = 10000000,
    nchains = 4,
    nruns = 4,
    stopval = 0.01,
    ...
) {
    # default list
    defaults <- list(
        ngen = as.integer(gen), 
        nchains = as.integer(nchains),
        nruns = as.integer(nruns),
        relburnin = "yes",
        samplefreq = 1000,
        printfreq = 5000,
        diagnfreq = 10000,
        checkfreq = 10000,
        savebrlens = "yes",
        starttree = "random", 
        stoprule = "yes", 
        stopval = stopval
    )

    pars <- modifyList(defaults, list(...))

    pars_cmd <- purrr::map_vec(1:length(pars), \(i){paste0(names(pars)[i], "=", as.character(pars[[i]]))}) %>% paste(collapse = " ")

    cmd <- paste0("mcmc ", pars_cmd, ";")
    return(cmd)
}

#' @rdname mrbayes
#' @export
#' @param loci_length Numeric vector. Length of each locus.
#' @param loci_name Character vector. Name of each locus.
#' @param protein_coding_loci Character vector. Names of protein-coding loci to partition further by
#'   codon position (`_pos1`, `_pos2`, `_pos3`).
mrbayes_partition_cmd <- function(
    loci_length,
    loci_name,
    protein_coding_loci
) {
    # Checks
    if (length(loci_length) != length(loci_name)) {cli::cli_abort("{.var loci_length} must have the same length as {.var loci_name}")}
    if (any(!protein_coding_loci %in% loci_name)) {cli::cli_abort("{.var protein_coding_loci} must be elements in {.var loci_name}")}

    partition.scheme <- data.frame(
        name = loci_name,
        length = loci_length
    ) %>%
        dplyr::mutate(
            protein_coding = ifelse(name %in% protein_coding_loci, T, F),
            end = cumsum(length),
            start = dplyr::lag(end, default = 0) + 1
        )

    partition <- purrr::map(1:nrow(partition.scheme), \(i){
        if (partition.scheme[i,]$protein_coding) {
            partition.names <- paste0(partition.scheme[i,]$name, c("_pos1", "_pos2", "_pos3"))
            p1 <- paste0("charset ", partition.names[1], " = ", partition.scheme[i,]$start, "-", partition.scheme[i,]$end, ".\\3;")
            p2 <- paste0("charset ", partition.names[2], " = ", partition.scheme[i,]$start+1, "-", partition.scheme[i,]$end, "-.\\3;")
            p3 <- paste0("charset ", partition.names[3], " = ", partition.scheme[i,]$start+2, "-", partition.scheme[i,]$end, ".\\3;")
            return(list(name = partition.names, charset = c(p1, p2, p3)))
        } else {
            partition.names <- partition.scheme[i,]$name
            p <- paste0("charset ", partition.scheme[i,]$name, " = ", partition.scheme[i,]$start, "-", partition.scheme[i,]$end, ";")
            return(list(name = partition.names, charset = c(p)))
        }
    })

    charset.lines <- purrr::map(partition, ~.x$charset) %>% unlist() %>% paste(collapse = "\n")
    partition.names <- purrr::map(partition, ~.x$name) %>% unlist()

    part.def <- paste0(
        "partition conc = ", 
        length(purrr::map(partition, ~.x$charset) %>% unlist()),
        ": ",
        paste(partition.names, collapse = ", "),
        ";"
    )

    cmd <- paste(
        charset.lines,
        part.def,
        "set partition = conc;",
        sep = "\n"
    )

    return(cmd)
}

#' @rdname mrbayes
#' @export
#' @param nst Numeric or integer. Value passed to `lset nst`.
#' @param rates Character. Value passed to `lset rates`.
#' @param applyto Numeric vector or `NULL`. Partition indices to apply `lset` settings to.
#'   Default is `NULL` (applies to the whole alignment).
mrbayes_lset_cmd <- function(
    nst,
    rates,
    ...,
    applyto = NULL
) {
    if (is.null(applyto)) {
        applyto <- ""
    } else {
        applyto <- paste0(" applyto=(", paste(applyto, collapse = ","), ")")
    }

    pars <- list(...)
    if (length(pars)==0) {
       pars_cmd <- ""
    } else {
        pars_cmd <- purrr::map_vec(1:length(pars), \(i){paste0(names(pars)[i], "=", as.character(pars[[i]]))}) %>% paste(collapse = " ")
    }

    cmd <- paste0("lset", applyto, " nst=", nst, " rates=", rates, " ", pars_cmd, ";")
    return(cmd)
}

#' @rdname mrbayes
#' @export
mrbayes_prset_cmd <- function(
    ...,
    applyto = NULL
) {
    if (is.null(applyto)) {
        applyto <- ""
    } else {
        applyto <- paste0(" applyto=(", paste(applyto, collapse = ","), ")")
    }

    pars <- list(...)
    if (length(pars)==0) {
       return(invisible(""))
    } else {
        pars_cmd <- purrr::map_vec(1:length(pars), \(i){paste0(names(pars)[i], "=", as.character(pars[[i]]))}) %>% paste(collapse = " ")
    }

    cmd <- paste0("prset", applyto, " ", pars_cmd, ";")
    return(cmd)
}

#' @rdname mrbayes
#' @export
#' @param cmd Character. Either `"sump"` or `"sumt"` when `...` arguments are supplied.
mrbayes_sum_cmd <- function(
    ...,
    cmd
) {
    pars <- list(...)
    if (length(pars)==0) {
        return("sump;\nsumt;")
    }
    pars_cmd <- purrr::map_vec(1:length(pars), \(i){paste0(names(pars)[i], "=", as.character(pars[[i]]))}) %>% paste(collapse = " ")

    sum_cmd <- paste0(cmd, " ", pars_cmd, ";")
    return(sum_cmd)
}

#' @rdname mrbayes
#' @export
mrbayes_block <- function(
    ...
) {
    cmds <- c(...)
    paste(
        "BEGIN MrBayes;",
        "set autoclose=yes;",
        paste(cmds, collapse = "\n\n"),
        "END;",
        sep = "\n\n"
    )
}

#' @name mrbayes-args
#' @rdname mrbayes
#' @param ... Additional arguments. \describe{
#'   \item{[mrbayes_mcmc_cmd()]}{Further parameters to include in the `mcmc` command.}
#'   \item{[mrbayes_lset_cmd()]}{Further parameters to include in the `lset` command.}
#'   \item{[mrbayes_prset_cmd()]}{Further parameters to include in the `prset` command.}
#'   \item{[mrbayes_sum_cmd()]}{Further parameters to include in `sumt` or `sump`; `cmd` must also be provided to specify `"sumt"` or `"sump"`.}
#'   \item{[mrbayes_block()]}{Commands to include inside the `MrBayes` block.}
#' }
NULL

#' Generate a NEXUS File with an Embedded MrBayes Block
#' 
#' @description
#' Sanitizes sequence labels, writes a `DNAbin` alignment to a NEXUS file, appends a generated
#' `MrBayes` block, and returns the output file path.
#' 
#' @seealso [mrbayes]
#' @export
#' 
#' @param alignment A `DNAbin` alignment object.
#' @param output_path Character. Output file path (with or without a `.nexus` extension).
#' @param mcmc_options Named list or `NULL`. Arguments passed to [mrbayes_mcmc_cmd()]. Default is `NULL`.
#' @param partition Logical. Whether to include a partition scheme generated by [mrbayes_partition_cmd()].
#'   Default is `TRUE`.
#' @param loci_length Numeric vector. Length of each locus, passed to [mrbayes_partition_cmd()].
#' @param loci_name Character vector. Name of each locus, passed to [mrbayes_partition_cmd()].
#' @param protein_coding_loci Character vector. Names of protein-coding loci, passed to [mrbayes_partition_cmd()].
#' @param lset_options Named list or list of named lists. Arguments passed to [mrbayes_lset_cmd()].
#' @param prset_options Named list, list of named lists, or `NULL`. Arguments passed to [mrbayes_prset_cmd()].
#'   Default is `NULL`.
#' @param sum_options Named list, list of named lists, or `NULL`. Arguments passed to [mrbayes_sum_cmd()].
#'   Default is `NULL`.
#' 
#' @return Character path to the written NEXUS file.
prepare_mrbayes_nexus <- function(
    alignment,
    output_path,
    mcmc_options = NULL,
    partition = T,
    loci_length,
    loci_name,
    protein_coding_loci,
    lset_options,
    prset_options = NULL,
    sum_options = NULL
){
    if (!is.null(mcmc_options)) {
        mcmc <- do.call(mrbayes_mcmc_cmd, mcmc_options)
    } else {
        mcmc <- ""
        cli::cli_alert_warning("MCMC option is empty.")
    }
    if (partition) {
        partition_arg <- mrbayes_partition_cmd(loci_length, loci_name, protein_coding_loci)
    } else {
        partition_arg <- ""
    }

    if (purrr::pluck_depth(lset_options) == 3) {
        lset <- purrr::map_vec(lset_options, ~do.call(mrbayes_lset_cmd, .x))
    } else if (purrr::pluck_depth(lset_options) == 2) {
        lset <- do.call(mrbayes_lset_cmd, lset_options)
    }

    if (purrr::pluck_depth(prset_options) == 3) {
        prset <- purrr::map_vec(prset_options, ~do.call(mrbayes_prset_cmd, .x))
    } else if (purrr::pluck_depth(prset_options) == 2) {
        prset <- do.call(mrbayes_prset_cmd, prset_options)
    } else if (is.null(prset_options)) {
        prset <- ""
    }

    if (purrr::pluck_depth(sum_options) == 3) {
        sum_cmd <- purrr::map_vec(sum_options, ~do.call(mrbayes_sum_cmd, .x))
    } else if (purrr::pluck_depth(sum_options) == 2) {
        sum_cmd <- do.call(mrbayes_sum_cmd, sum_options)
    } else if (is.null(sum_options)) {
        sum_cmd <- mrbayes_sum_cmd()
    }

    arg_ls <- list(
        mcmc,
        lset,
        prset,
        sum_cmd
    )

    if (partition) {
        arg_ls <- c(partition_arg, arg_ls)
    }

    mrbayes_block <- do.call(mrbayes_block, arg_ls)

    # use safe name
    names(alignment) <- zhutilsr::.safe_name(names(alignment))

    dir.create(dirname(output_path), recursive = T)
    file_output_path <- ifelse(stringr::str_detect(output_path, "\\.nexus$"), output_path, paste0(output_path, ".nexus"))

    ape::write.nexus.data(alignment, file_output_path, interleaved = F)
    write(mrbayes_block, file_output_path, append = T)

    # TODO: SUMMARY

    return(file_output_path)
}