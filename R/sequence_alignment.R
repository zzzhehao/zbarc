#' Align Sequences Using MAFFT
#'
#' @param input Character. Path to input FASTA file.
#' @param output Character. Path to output aligned FASTA file.
#' @param browse Logical. If `TRUE`, opens the resulting alignment in a browser via
#'   [DECIPHER::BrowseSeqs()]. Default is `TRUE`.
#' @param args Character vector or `NULL`. Additional CLI arguments passed to `mafft`.
#'   Default is `NULL`.
#'
#' @return Invisibly returns the integer exit status code from `system2("mafft", ...)`.
#' @export
mafft <- function(
    input,
    output,
    browse = TRUE,
    args = NULL
) {
    mafft.err <- tempfile("maffterr", fileext = ".txt")
    on.exit(unlink(mafft.err), add = TRUE)

    status_code <- system2(
        command = "mafft",
        args = c("--auto", "--quiet", input, args), # Separated flags
        stdout = output,                      # Output to file
        stderr = mafft.err                       # Errors to file (fixes the R warning)
    )

    # 3. Check the integer status code directly
    if (status_code != 0) {
        # Read the error log back into R to show the user
        err_msg <- paste(readLines(mafft.err), collapse = "\n")
        stop("MAFFT failed with exit status: ", status_code, 
            "\nMAFFT Error log:\n", err_msg)
    }

    if (browse) {
        DECIPHER::BrowseSeqs(Biostrings::readDNAStringSet(output))
    }

    return(invisible(status_code))
}

#' Polish Sequence Alignment
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#' Deprecated in version `0.0.1.9001` because alignment polishing in DNA barcoding is better
#' performed manually with visual inspection.
#' 
#' @param aln A `DNAbin` alignment object.
#' @param verbose Logical. Whether to print status messages via `cli`. Default is `TRUE`.
#'
#' @return A `DNAbin` object containing the polished alignment.
#' @export
polish_alignment <- function(
    aln,
    verbose = T
) {
    lifecycle::deprecate_warn(
        when = "0.0.1.9001",
        what = "polish_alignment()"
    )
    aln_mat <- do.call(rbind, as.character(aln))

    # insertions
    col_gap_freqs <- colMeans(aln_mat == "-")
    is_insertion_col <- col_gap_freqs >= 0.75
    ins_rle <- rle(is_insertion_col) # isertion width check
    ins_invalid <- ins_rle$values == TRUE & (ins_rle$lengths %% 3 != 0)
    ins_invalid_cols <- rep(ins_invalid, ins_rle$lengths) # to column indices
    aln_mat[, ins_invalid_cols] <- "-" # erase

    # report
    if (verbose) {
        if (any(ins_invalid)) {
            cli::cli_alert_danger(
                "There were frame-shifting insertions at alignment pos {paste(which(ins_invalid_cols), sep = ', ')}. Insertions are deleted."
            )
        }
    }

    # deletions
    find_invalid_gaps <- function(seq_row) {
        del_r <- rle(seq_row == "-")
        del_invalid <- del_r$values == TRUE & (del_r$lengths %% 3 != 0)
        
        if (del_r$values[1] == TRUE) del_invalid[1] <- FALSE # head
        if (tail(del_r$values, 1) == TRUE) del_invalid[length(del_invalid)] <- FALSE # tail
        
        return(rep(del_invalid, del_r$lengths))
    }

    del_invalid_cols <- t(apply(aln_mat, 1, find_invalid_gaps))

    # col consensus
    get_consensus <- function(col) {
        # all gaps
        bases <- col[col != "-"]
        if (length(bases) == 0) return("-")
        
        tbl <- table(bases)
        top_base <- names(tbl)[which.max(tbl)]
        top_freq <- max(tbl) / length(bases)
        
        # 75% threshold for consensus
        if (top_freq >= 0.75) return(top_base) else return("N")
    }
    col_consensus <- apply(aln_mat, 2, get_consensus)

    # guess invalid deletions
    aln_mat[del_invalid_cols] <- col_consensus[col(aln_mat)][del_invalid_cols]

    # clean
    all_gap_cols <- colMeans(aln_mat == "-") == 1
    aln_mat_clean <- aln_mat[, !all_gap_cols]

    if (verbose) {
        if (any(del_invalid_cols)) {
            cli::cli_alert_danger(
                "There were frame-shifting deletions at alignment pos {paste(which(del_invalid_cols), sep = ', ')}. Deletions are guessed with alignment consensus when >75% of the sequences agree on one, or left as `N` when no consensus could be agreed."
            )
        }
    }

    if (verbose) {
        if (all(!ins_invalid_cols, !del_invalid_cols)) {
            cli::cli_alert_success("No frame-shifting indel found. Your alignment is clean.")
        }
    }

    polished_alignment <- Biostrings::DNAStringSet(apply(aln_mat_clean, 1, paste, collapse="")) %>% ape::as.DNAbin()
    names(polished_alignment) <- names(aln)
    return(polished_alignment)
}

#' Visually Compare Original and Polished Alignments with MAFFT
#'
#' @param aln.old A `DNAbin` alignment object before polishing.
#' @param aln.clean A `DNAbin` alignment object after polishing.
#'
#' @return Invisibly returns the combined re-aligned sequences as a `DNAbin` object.
#' @export
check_polish <- function(
    aln.old,
    aln.clean 
) {
    names(aln.clean) <- names(aln.clean) %>% paste0(., "_clean")
    aln.comb <- c(aln.old, aln.clean)
    aln.comb <- aln.comb[names(aln.comb) %>% order()] # order by name for compare

    # 1. Create temp files for input, output, AND errors
    mafft.in <- tempfile("mafftin", fileext = ".fasta")
    mafft.out <- tempfile("mafftout", fileext = ".fasta")
    mafft.err <- tempfile("maffterr", fileext = ".txt")
    
    # Clean up all three files on exit
    on.exit(unlink(c(mafft.in, mafft.out, mafft.err)), add = TRUE)

    ape::write.FASTA(aln.comb, mafft.in)

    cli::cli_alert_info("MAFFT running ... this might take a few moment")
    # 2. Execute system2 with separated args and pure file redirection
    status_code <- system2(
        command = "mafft",
        args = c("--auto", "--quiet", mafft.in), # Separated flags
        stdout = mafft.out,                      # Output to file
        stderr = mafft.err                       # Errors to file (fixes the R warning)
    )

    # 3. Check the integer status code directly
    if (status_code != 0) {
        # Read the error log back into R to show the user
        err_msg <- paste(readLines(mafft.err), collapse = "\n")
        stop("MAFFT failed with exit status: ", status_code, 
            "\nMAFFT Error log:\n", err_msg)
    }

    # 4. Process results
    aln.check <- Biostrings::readDNAStringSet(mafft.out)
    DECIPHER::BrowseSeqs(aln.check)
    return(invisible(ape::as.DNAbin(aln.check)))
}

#' Check Stop Codons and Reading Frames in a Protein-Coding Alignment
#'
#' @param aln A named `DNAbin` alignment object.
#' @param code Integer or character. Genetic code passed to `code` in [ape::trans()].
#' @param verbose Logical. Whether to print status messages via `cli`. Default is `TRUE`.
#'
#' @return Invisibly returns a named list with elements `raw`, `tbl`, and `result`.
#' @export
codon_summary <- function(
    aln, 
    code,
    verbose = T
) {
    contig_names <- names(aln)
    stopcodon.summary <- contig_names %>% purrr::map(\(seqname){
        seq <- aln[seqname]
    
        # clean aln gaps
        gaps <- seq %>% as.character() %>% unlist == "-"
        seq[[1]] <- seq[[1]][!gaps]
    
        # summary init
        trans <- data.frame(
            stopcodon = T,
            count = 1,
            loc = 1
        )
    
        headtrim = -1
        seqsc <- seq
    
        while (
            any(trans$stopcodon) &&
            any(trans$count == 1) &&
            any(purrr::discard(trans$loc, is.na) <= 3)
        ) {
            trans <- purrr::map_dfr(1:3, \(i){
                aa <- ape::trans(seqsc, code = code, codonstart = i)
                stopcodon <- as.character(aa) %>% unlist() == "*"
                stopcodon.res <- any(stopcodon)
                count <- sum(stopcodon)
                loc <- which(stopcodon)
                if (length(loc) == 0) {loc <- NA}
                loc_first <- loc[[1]]
                data.frame(
                    seq = seqname, 
                    frame = i, 
                    stopcodon = stopcodon.res[[1]], 
                    count = count, 
                    loc = loc_first)
            }) %>% tibble::remove_rownames()
    
            seqsc[[1]] <- seqsc[[1]][-(1:3)]
            headtrim <- headtrim + 1
        }
    
        return(list(summary = trans, headtrim_step = headtrim, seq = seq))
    })
    
    stopcodon.summary.tbl <- purrr::map_dfr(stopcodon.summary, \(x){
        x$summary
    })

    stopcodon.summary.res <- stopcodon.summary.tbl %>% 
        dplyr::group_by(seq) %>% 
        dplyr::group_map(~ {
            if (any(!.x$stopcodon)) {
                data.frame(seq = .y[1,1], stopcodon = FALSE)
            } else {
                data.frame(seq = .y[1,1], stopcodon = TRUE)
            }
        }) %>% 
        dplyr::bind_rows()

    trim.scheme <- stopcodon.summary %>% purrr::map_dfr(\(x){
        frame <- x$summary %>% dplyr::filter(!stopcodon) %>% .[1,] %>% .$frame
        trimstep <- x$headtrim_step
        trimbp <- trimstep*3 + frame - 1
        return(data.frame(seq = x$summary[1,1], trim_bp = trimbp))
    })

    stopcodon.summary.res <- dplyr::left_join(stopcodon.summary.res, trim.scheme)

    if (all(contig_names %in% (stopcodon.summary.tbl %>% dplyr::filter(!stopcodon) %>% .$seq))) {
        if (verbose) {
            cli::cli_alert_success("All contig has a reading frame without stop codon")
        }
        fail <- NULL
    } else {
        fail <- contig_names[which(!contig_names %in% (stopcodon.summary.tbl %>% dplyr::filter(!stopcodon) %>% .$seq))]
        if (verbose) {
            cli::cli_alert_warning("Contigs {paste(fail)} contain stop codon at all three reading frames. Check direction.")
        }
    }

    if (verbose) {
        cli::cli_alert_info("Codon check completed. You can access summaries by `.$raw`, `.$tbl`, or `.$result`.")
    }

    return(invisible(list(raw = stopcodon.summary, tbl = stopcodon.summary.tbl, result = stopcodon.summary.res)))
}

#' Remove Empty Columns from an Alignment
#'
#' @description 
#' Scans a `DNAbin` alignment and removes any columns (positions) where 
#' all sequences consist entirely of specified target characters, such as gaps (`-`), 
#' ambiguous bases (`N`), or missing data (`?`).
#'
#' @param x A `DNAbin` object (matrix, list, or vector). If provided as a list, 
#'   all sequences must have the same length.
#' @param chars Character vector specifying which bases should be treated as "empty". 
#'   Defaults to `c("-", "n", "?")` (case-insensitive).
#'
#' @return A `DNAbin` object of the same structure as `x` with empty columns removed.
#' @export
trim_empty_columns <- function(x, chars = c("-", "n", "?")) {
    
    # 1. Type verification
    if (!inherits(x, "DNAbin")) {
        stop("Input must be a 'DNAbin' object.")
    }
    
    # 2. Check structure and enforce equal lengths (alignment requirement)
    was_list <- FALSE
    if (is.list(x)) {
        lens <- lengths(x)
        if (length(unique(lens)) > 1) {
            stop(
                "Cannot extract columns from sequences of different lengths. ",
                "Please align the sequences first or ensure they are padded to the same length."
            )
        }
        x_mat <- as.matrix(x)
        was_list <- TRUE
    } else if (is.matrix(x)) {
        x_mat <- x
    } else {
        # Fallback for single vectors (1D)
        x_mat <- as.matrix(x)
    }
    
    # 3. Convert user characters into ape's internal raw byte format
    # This prevents the need to run as.character() on a massive alignment matrix
    target_raw <- as.vector(ape::as.DNAbin(matrix(tolower(chars), nrow = 1)))
    
    # 4. Identify matching elements across the entire matrix (returns flat logical vector)
    match_logical <- x_mat %in% target_raw
    
    # Reshape back into matrix form
    match_mat <- matrix(match_logical, nrow = nrow(x_mat), ncol = ncol(x_mat))
    
    # 5. Identify columns where ALL elements are TRUE (i.e., colSum equals number of rows)
    col_is_empty <- colSums(match_mat) == nrow(x_mat)
    
    # 6. Keep only columns that are NOT entirely empty
    res_mat <- x_mat[, !col_is_empty, drop = FALSE]
    class(res_mat) <- "DNAbin"
    
    # 7. Return in the same format the user provided
    if (was_list) {
        return(as.list(res_mat))
    }
    
    return(res_mat)
}