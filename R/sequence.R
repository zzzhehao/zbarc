#' Clean Sequence Labels in a FASTA Alignment
#' 
#' @description
#' Formats sequence labels in a FASTA file by appending the detected gene name (`COI`, `18S`,
#' `28S`, or `16S`) from `basename(fasta_path)` to voucher IDs matching `^VPS[0-9]{3}` or
#' `^ZHH[0-9]{3}`, and strips trailing `.1` or `.1_(reversed)` suffixes from sequence names.
#' 
#' @param fasta_path Character. Path to the input FASTA file.
#' @param noprefix Logical. If `TRUE`, strips leading `ZHH` or `VPS` prefixes from sequence labels.
#'   Default is `FALSE`.
#'
#' @return Character path to the newly written `*_cleaned.fasta` file in the same directory.
#' @export
clean_label <- function(fasta_path, noprefix = F){
    genes <- c("COI", "18S", "28S", "16S")
    gene <- genes[stringr::str_detect(basename(fasta_path), paste(genes, sep = "|"))]
    aln <- ape::read.FASTA(fasta_path) 
    names(aln) <- names(aln) %>%
        # VPS formatting
        ifelse(
            stringr::str_detect(., "^VPS[0-9]{3}"), 
            stringr::str_extract(., "^VPS[0-9]{3}") %>% paste0(., "_", gene), 
            .) %>%
        # ZHH formatting
        ifelse(
            stringr::str_detect(., "^ZHH[0-9]{3}"), 
            stringr::str_extract(., "^ZHH[0-9]{3}") %>% paste0(., "_", gene), 
            .) %>%
        # NCBI accession number formatting (to primary)
        ifelse(stringr::str_detect(., "\\.1$"), gsub("\\.1$", "", .), .) %>%
        ifelse(stringr::str_detect(., "\\.1_\\(reversed\\)$"), gsub("\\.1_\\(reversed\\)$", "", .), .)

    if (noprefix) {
        # SHIT CODE HERE
        names(aln) <- names(aln) %>%
            ifelse(stringr::str_detect(., "^ZHH|^VPS"), gsub("^ZHH|^VPS", "", .), .)
    }
    new_fasta_path <- paste0(dirname(fasta_path), "/", gsub("\\.fasta$", "", basename(fasta_path)), "_cleaned.fasta")
    ape::write.FASTA(aln, new_fasta_path)
    return(new_fasta_path)
}

#' Trim Conserved Alignment Blocks with Gblocks
#'
#' @description 
#' User-facing wrapper for Gblocks that executes alignment trimming, renames Gblocks' default
#' output file cleanly (e.g., `_gb.fasta`), and returns the output file path.
#'
#' @param input Character. Path to the input FASTA file.
#' @param output Character or `NULL`. Custom path for the trimmed FASTA file. If `NULL` (default),
#'   inserts `_gb` before the file extension.
#' @param t Character. Sequence type: `"d"` (DNA), `"p"` (Protein), or `"c"` (Codons). Default is `"d"`.
#' @param b1 Numeric or `"min"`. Minimum number of sequences for a conserved position. When `"min"`,
#'   calculated as `ceiling(n_seq / 2) + 1`. Default is `"min"`.
#' @param b2 Numeric or `"min"`. Minimum number of sequences for a flank position. When `"min"`,
#'   equals `b1`. Default is `"min"`.
#' @param b3 Integer. Maximum number of contiguous non-conserved positions. Default is `20`.
#' @param b4 Integer. Minimum block length. Default is `2`.
#' @param b5 Character. Allowed gap positions: `"a"` (All), `"h"` (Half), or `"n"` (None). Default is `"a"`.
#' @param args Character vector or `NULL`. Additional CLI arguments passed to Gblocks. Default is `NULL`.
#' @param exec Character. Path or command for the Gblocks executable. Default is `"Gblocks"`.
#' @param browse Logical. If `TRUE`, opens the generated HTML visualization in a browser. Default is `TRUE`.
#' 
#' @return Character path to the trimmed FASTA alignment file.
#' @export
gblocks <- function(
    input,
    output = NULL,
    t = "d",
    b1 = "min",
    b2 = "min",
    b3 = 20,
    b4 = 2,
    b5 = "a",
    args = NULL,
    exec = "Gblocks",
    browse = TRUE
) {
    if (is.null(output)) {
        if (grepl("\\.[a-zA-Z0-9]+$", input)) {
            output <- sub("(\\.[a-zA-Z0-9]+)$", "_gb\\1", input)
        } else {
            output <- paste0(input, "_gb")
        }
    }
    
    output_htm <- paste0(output, ".html")

    .gblocks(
        input = input,
        output = output,
        t = t,
        b1 = b1,
        b2 = b2,
        b3 = b3,
        b4 = b4,
        b5 = b5,
        args = args,
        exec = exec,
        browse = browse
    )

    cat("Trimmed alignment successfully saved to:\n  ", output, "\n")
    if (file.exists(output_htm)) {
        cat("HTML visualization saved to:\n  ", output_htm, "\n")
    }

    return(output)
}

#' Internal Gblocks Execution Helper
#'
#' @inheritParams gblocks
#' @return Invisibly returns the integer exit status code from `system2()`.
#' @noRd
.gblocks <- function(
    input,
    output,
    t = "d",
    b1 = "min",
    b2 = "min",
    b3 = 20,
    b4 = 2,
    b5 = "a",
    args = NULL,
    exec = "Gblocks",
    browse = TRUE
) {
    # 1. Input validation & convert to absolute path
    if (!file.exists(input)) {
        stop("Input file does not exist: ", input)
    }
    input <- normalizePath(input, mustWork = TRUE)
    
    # 2. Calculate dynamic b1 and b2 ('min' parameters)
    if (b1 == "min" || b2 == "min") {
        nseq <- length(ape::read.FASTA(input))
        if (b1 == "min") b1 <- ceiling(nseq / 2) + 1
        if (b2 == "min") b2 <- b1
    }
    
    b1 <- as.numeric(b1)
    b2 <- as.numeric(b2)
    
    if (is.na(b1) || is.na(b2)) {
        stop("Arguments 'b1' and 'b2' must be numeric or 'min'.")
    }

    # 3. Setup temporary logs and identify Gblocks auto-generated files
    gblocks.err <- tempfile("gblockserr", fileext = ".txt")
    gblocks_auto_out <- paste0(input, "-gb")
    gblocks_auto_htm <- paste0(input, "-gb.htm")
    output_htm <- paste0(output, ".htm")
    
    # Ensure temporary and auto-generated files in the input directory are cleaned up 
    # (they will be removed if the function crashes before they are relocated to `output`)
    on.exit({
        unlink(gblocks.err)
        if (file.exists(gblocks_auto_out)) unlink(gblocks_auto_out)
        if (file.exists(gblocks_auto_htm)) unlink(gblocks_auto_htm)
    }, add = TRUE)

    # 4. Construct the argument vector for system2
    cmd_args <- c(
        input,
        paste0("-t=", t),
        paste0("-b1=", b1),
        paste0("-b2=", b2),
        paste0("-b3=", b3),
        paste0("-b4=", b4),
        paste0("-b5=", b5),
        args
    )

    # 5. Execute Gblocks
    status_code <- suppressWarnings(
        system2(
            command = exec,
            args = cmd_args,
            stdout = gblocks.err, 
            stderr = gblocks.err  
        )
    )

    # 6. Error handling: check if output was actually generated
    if (!file.exists(gblocks_auto_out)) {
        err_msg <- paste(readLines(gblocks.err), collapse = "\n")
        stop("Gblocks failed to generate output. Exit status: ", status_code, 
             "\nCommand attempted: ", paste(c(exec, cmd_args), collapse = " "),
             "\nGblocks Console Log:\n", err_msg)
    }

    # 7. Relocate standard FASTA output to user's desired destination
    file.copy(gblocks_auto_out, output, overwrite = TRUE)
    unlink(gblocks_auto_out) # Clean it up manually so on.exit doesn't try to find it

    # 8. Relocate HTML visualization and open in browser if requested
    if (file.exists(gblocks_auto_htm)) {
        file.copy(gblocks_auto_htm, output_htm, overwrite = TRUE)
        unlink(gblocks_auto_htm)
        
        if (browse) {
            # Use normalizePath so the browser gets a valid absolute path for the local file
            utils::browseURL(normalizePath(output_htm, mustWork = TRUE))
        }
    }

    return(invisible(status_code))
}

#' Convert a NEXUS Alignment to FASTA Format
#'
#' @param nexus_path Character. Path to the input NEXUS alignment file.
#' @param fasta_path Character or `NULL`. Path for the output FASTA file. If `NULL`, replaces
#'   `\\.nexus$` in `nexus_path` with `.fasta`.
#' @param safe_name Logical. Whether to remove underscores (`_`) from sequence labels. Default is `FALSE`.
#' @param remove_outgroup Character vector or `NULL`. Sequence labels to drop before renaming.
#'   Default is `NULL`.
#'
#' @return Character path to the written FASTA file.
#' @export
convert_nexus2fasta <- function(nexus_path, fasta_path=NULL, safe_name=F, remove_outgroup=NULL) {
    if (is.null(fasta_path)) {
        fasta_path <- gsub("\\.nexus$", ".fasta", nexus_path)
    }
    dir.create(dirname(fasta_path))
    aln <- ape::read.nexus.data(nexus_path) %>% ape::as.DNAbin()

    if (!is.null(remove_outgroup)) {
        aln <- aln[!names(aln) %in% remove_outgroup]
    }

    if (safe_name) {
        name <- names(aln) %>% gsub("_", "", .)
        names(aln) <- name
    }
    ape::write.FASTA(aln, fasta_path)
    return(fasta_path)
}

#' Write MRCA Priors into a NEXUS Alignment File for BEAST2
#' 
#' @description
#' Appends a `BEGIN sets;` block defining `taxset` monophyly constraints to a NEXUS file so
#' they can be loaded into BEAUti and BEAST2 (e.g., to constrain outgroups for ultrametric trees).
#' 
#' @param nexus Character. Path to the target NEXUS alignment file.
#' @param monophyly_groups List of lists, where each element specifies one monophyly group:
#'   \describe{
#'     \item{`name`}{Character string of length 1 naming the `taxset`.}
#'     \item{`labels`}{Character vector of taxon labels matching those in the alignment.}
#'   }
#'
#' @return Invisibly returns the result of `write()`.
#' @export
beast2_write_mrca <- function(nexus, monophyly_groups) {
    MRCA <- purrr::map_vec(monophyly_groups, \(g){
        name <- g[["name"]]
        labels <- g[["labels"]]
        group.block <- paste(labels, collapse = " ") %>% paste0("taxset ", name, " = ", ., ";")
        return(group.block)
    }) %>%
        paste("BEGIN sets;", ., "END;", sep = "\n")    
    write(MRCA, nexus, append = T, sep = "\n")
}

#' Run Automatic Barcoding Gap Discovery (ABGD)
#' 
#' @param alignment Character. Path to the input FASTA alignment file.
#' @param exe Character. Path to the ABGD executable.
#' @param output_folder Character or `NULL`. Output directory path. Defaults to `file.path(dirname(alignment), "ABGD")`.
#' @param a Logical. Whether to pass `-a` to ABGD. Default is `TRUE`.
#' @param p Numeric. Minimum a priori intraspecific divergence (`Pmin`). Default is `0.001`.
#' @param P Numeric. Maximum a priori intraspecific divergence (`Pmax`). Default is `0.1`.
#' @param n Integer. Number of steps in `[Pmin, Pmax]`. Default is `20`.
#' @param d Integer. Genetic distance option: `0` = Kimura-2P, `1` = Jukes-Cantor, `2` = Tamura-Nei,
#'   `3` = simple p-distance. Default is `3`.
#' @param X Numeric. Minimum relative gap width / slope increase (`X`). Default is `1.5`.
#' @param args Character or `NULL`. Additional CLI arguments passed to ABGD. Default is `NULL`.
#' @param overwrite Logical. Whether to overwrite `output_folder` if it already contains files.
#'   Default is `FALSE`.
#'
#' @return Character path to `output_folder`.
#' @seealso [abgd_read_result()], [abgd_read_result_all()], [abgd_summary()], [abgd_delim()]
#' @export
abgd_execute <- function(
    alignment, exe, output_folder = NULL, 
    a = T, p = 0.001, P = 0.1, n = 20, d = 3, X = 1.5, args = NULL,
    overwrite = F
) {
    if (is.null(output_folder)) {
        output_folder <- paste0(dirname(alignment), "/ABGD")
    } 
    if (a) {
        args <- paste("-a", args)
    }

    # check output folder
    exist <- dir.exists(output_folder) & length(list.files(output_folder) > 0)
    if (!overwrite & exist) {
        cli::cli_abort("Output folder already exists. Use `overwrite = TRUE` to overwrite.")
    }
    if (!exist) {
        dir.create(output_folder, recursive = T)
    } else {
        file.remove(list.files(output_folder, full.names = TRUE, recursive = TRUE))
    }

    abgd_cmd <- paste(
        exe,
        "-p", p,
        "-P", P,
        "-n", n,
        "-d", d,
        "-X", X,
        "-o", output_folder,
        args,
        alignment,
        collapse = " "
    ) %>% gsub("  ", " ", .)

    cli::cli_alert_info(paste0("Executing ABGD command: \n\n", abgd_cmd))
    system(abgd_cmd)

    # ABGD program produce the distmat.txt always at the working directory. Clean this mess up.
    distmat <- list.files(getwd(), paste0(basename(alignment) %>% gsub("\\.fasta$", "", .), "_distmat\\.txt$"), full.names = T)
    cat(distmat)
    distmat_output <- paste(output_folder, basename(distmat), sep = "/")
    cat(distmat_output)
    file.rename(distmat, distmat_output)

    return(output_folder)
}

#' Plot Distance Histogram from an ABGD Distance Matrix File
#'
#' @param distmat_path Character. Path to the `*_distmat.txt` file generated by ABGD.
#' 
#' @return A `ggplot` histogram object.
#' @seealso [abgd_execute()]
#' @export
abgd_disthist <- function(distmat_path) {
    distmat_raw <- read.table(distmat_path, sep = " ", skip = 1)
    distmat.plot <- distmat_raw[,-1] %>% 
        tidyr::pivot_longer(dplyr::everything()) %>% 
        ggplot2::ggplot() +
        ggplot2::geom_histogram(ggplot2::aes(x = value))
    return(distmat.plot)
}

#' Read a Single ABGD Partition Result File
#' 
#' @description
#' Parses an ABGD partition output file (`part*.txt`) into a long-format `data.frame` of
#' `taxa` and `group` assignments.
#'
#' @param path Character. Path to an ABGD partition text file.
#'
#' @return A `data.frame` (tibble) with columns `taxa` (character) and `group` (factor).
#' @seealso [abgd_execute()], [abgd_read_result_all()], [abgd_summary()], [abgd_delim()]
#' @export
abgd_read_result <- function(path) {
    delim <- readr::read_delim(path, delim = ";", col_names = c("labels"), col_types = "c")
    delim <- delim %>% 
        dplyr::mutate(
            taxa = gsub("^id: ", "", X2),
            group = gsub("^Group\\[ ", "", labels) %>% 
                gsub(" \\].*$", "", .) %>%
                as.factor(),
            .keep = "none"
        ) %>%
        tidyr::separate_longer_delim(taxa, " ")
    return(delim)
}

#' Read All ABGD Partition Results in a Directory
#' 
#' @description
#' Loads all initial and recursive ABGD partition files in `output_folder` along with metadata
#' such as partition type, index, and group count.
#'
#' @param output_folder Character. Path to the ABGD output directory.
#'
#' @return A list of lists containing `path`, `partition_type`, `index`, `group_count`, and `result`
#'   for each partition file.
#' @seealso [abgd_execute()], [abgd_read_result()], [abgd_summary()], [abgd_delim()]
#' @export
abgd_read_result_all <- function(output_folder) {
    part.files <- list.files(output_folder, pattern = regex("part(init)?\\.[0-9]+\\.txt$"), full.names = T)
    cvs.file <- list.files(output_folder, pattern = regex("res.cvs$"), full.names = T)
    res <- read.table(cvs.file, T, "\t")
    
    abgd.summary <- purrr::map(part.files, \(path){
        partition <- ifelse(stringr::str_detect(path, "partinit"), "initial", "recursive")
        index <- stringr::str_extract(path, "[0-9]+\\.txt$") %>% gsub("\\.txt", "", .) %>% as.numeric()
        list(
            path = path,
            partition_type = partition, 
            index = index,
            group_count = length(levels(abgd_read_result(path)$group)),
            result = abgd_read_result(path)
        )
    })
    return(abgd.summary)
}

#' Summarize ABGD Partitions and Plot Group Counts
#' 
#' @param output_folder Character. Path to the ABGD output folder.
#' @param silent Logical. If `FALSE`, prints the summary plot. Default is `FALSE`.
#' @param text.partition.size Numeric. Text size for prior divergence labels above points.
#'   Default is `3.4`.
#' 
#' @return A named list of length 2:
#'   \describe{
#'     \item{`plot`}{A `ggplot` object showing initial and recursive group counts across partitions.}
#'     \item{`summary`}{A `data.frame` summarizing `index`, `initial`, `recursive`, `fine_group`,
#'       `fine_group_prop`, and `prior` intraspecific divergence.}
#'   }
#' @seealso [abgd_execute()], [abgd_read_result()], [abgd_read_result_all()], [abgd_delim()]
#' @export
abgd_summary <- function(
    output_folder, 
    silent = F,
    text.partition.size = 3.4
) {
    abgd.res <- abgd_read_result_all(output_folder)
    cvs.file <- list.files(output_folder, pattern = regex("res.cvs$"), full.names = T)
    res <- read.table(cvs.file, T, "\t")
    abgd.summary <- abgd.res %>% 
        rlist::list.select(partition_type, index, group_count) %>% 
        dplyr::bind_rows() %>% 
        dplyr::arrange(partition_type, index) %>%
        tidyr::pivot_wider(names_from = partition_type, values_from = group_count) %>%
        dplyr::mutate(
            fine_group = recursive - initial,
            fine_group_prop = round(fine_group / recursive, 2)
        )
    
    abgd.summary <- dplyr::bind_cols(abgd.summary, res[1:nrow(abgd.summary),]["prior"])
    summary.plot <- 
        abgd.summary %>% 
        dplyr::filter(initial >= 2) %>%
        ggplot2::ggplot() +
        ggplot2::geom_point(ggplot2::aes(x = index, y = initial), shape = 1) +
        ggplot2::geom_point(ggplot2::aes(x = index, y = recursive), shape = 16) +
        ggplot2::geom_text(
            ggplot2::aes(x = index, y = max(abgd.summary$recursive)*1.1, label = round(prior, 4)),
            angle = 45, hjust = 0, size = text.partition.size
        ) +
        ggplot2::scale_x_continuous(
            # n.breaks = nrow(abgd.summary %>% dplyr::filter(initial >= 2)), 
            breaks = (1:floor(nrow(abgd.summary %>% dplyr::filter(initial >= 2))/5))*5,
            expand = expansion(add = c(1, 1.5))) +
        ggplot2::scale_y_continuous(expand = expansion(mult = c(0.2, 0.5))) +
        theme_minimal() +
        theme(
            aspect.ratio = 0.5,
            axis.line.x.bottom = ggplot2::element_line(color = "black", linewidth = 0.5),
            axis.line.y.left = ggplot2::element_line(color = "black", linewidth = 0.5),
            panel.grid.minor.x = ggplot2::element_blank()
        ) +
        labs(x = "Partition", y = "Groups found", title = "ABGD Number of Groups", subtitle = "Solid point: recursive partition; hollow point: initial partition. \nNumber above points: prior intraspecific divergence")
    if (!silent) {print(summary.plot)}
    return(list(plot = summary.plot, summary = abgd.summary))
}

#' Extract Species Delimitation Table from ABGD Recursive Partitions
#' 
#' @param output_folder Character. Path to the ABGD output folder.
#' @param indices Numeric or integer vector. Partition indices to extract from recursive partitions.
#' @param label Character vector or `NULL`. Suffix(es) appended to `"abgd_"` to name output
#'   columns; must match `length(indices)` when `length(indices) > 1`. If `NULL` and `length(indices) == 1`,
#'   the column is named `"abgd"`.
#' 
#' @return A `data.frame` (tibble) with column `taxa` and one delimitation column per selected partition.
#' @seealso [abgd_execute()], [abgd_read_result()], [abgd_read_result_all()], [abgd_summary()]
#' @export
abgd_delim <- function(output_folder, indices, label = NULL) {
    abgd.res <- abgd_read_result_all(output_folder)
    abgd.res.select <- abgd.res %>%
        rlist::list.filter(partition_type == "recursive") %>%
        rlist::list.filter(index %in% indices)
    if (is.null(label) & length(indices) > 1) {cli::cli_abort("When more than one partition results are evaluated, respective number of labels to differentiate each partition are required.")}
    if (is.null(label)) {
        label <- c("abgd")
    } else {
        label <- paste0("abgd_", label)
    }
    list.order <- rlist::list.select(abgd.res.select, index) %>% unlist()
    
    abgd.delim.res <- abgd.res.select %>%
        purrr::map2(label[match(list.order, indices)], \(res, lab) {
            tibble::tibble(
                taxa = res$result$taxa,
                !!lab := res$result$group
            )
        }) %>%
        purrr::reduce(~dplyr::left_join(.x, .y, by = "taxa"))
    return(abgd.delim.res)
}

#' Perform GMYC Species Delimitation on a BEAST2 Tree
#' 
#' @param contree Character. File path to a binary, ultrametric NEXUS tree (e.g., maximum clade
#'   credibility tree from BEAST2).
#' @param prefix Character or `NULL`. Optional prefix prepended to output column names.
#' @param method Character. GMYC threshold method: `"single"`, `"multiple"`, or `"both"`.
#'   Default is `"both"`.
#'
#' @return A `data.frame` containing `identifier` and delimited species columns for the requested method(s).
#' @seealso [beast2_write_mrca()]
#' @export
gmyc_eval <- function(contree, prefix = NULL, method = "both") {
    contree <- ape::read.nexus(contree)
    if (!ape::is.binary(contree) | !ape::is.ultrametric(contree)) {cli::cli_abort("The tree is not binary or ultrametric.")}
    if (method == "both") {method <- c("single", "multiple")}
    res <- purrr::map(method, \(m){
        if (!is.null(prefix)) {
            col_name <- paste0(prefix, "_gmyc_", m) %>% gsub("^_", "", .)
        } else {
            col_name <- paste0("gmyc_", m) %>% gsub("^_", "", .)
        }
        splits::gmyc(contree, method = m) %>% splits::spec.list() %>% rename(identifier = sample_name, !!col_name := GMYC_spec)
    }) %>% 
        purrr::reduce(~dplyr::left_join(.x, .y, by = "identifier")) %>%
        dplyr::select(identifier, dplyr::everything())
    return(res)
}

#' Run Substitution Model Selection (ModelFinder) in IQ-TREE
#' 
#' @description
#' Copies a FASTA alignment into a dedicated run subdirectory, generates a shell script, and
#' executes IQ-TREE with `-m MF` to test substitution models.
#' 
#' @param fasta_path Character. Path to the input FASTA alignment file.
#' @param run_name Character. Run label used to create the subdirectory and output prefix.
#' @param output_folder Character. Base parent folder where `run_name` will be created.
#' @param iqtree_exe Character. Path to the IQ-TREE executable.
#' 
#' @return Character path to the created run output directory (`file.path(output_folder, run_name)`).
#' @export
test_sub_model <- function(
    fasta_path,
    run_name,
    output_folder,
    iqtree_exe = "/Users/hu_zhehao/Desktop/utils/biology-tools/iqtree-2.3.6-macOS-arm/bin/iqtree2" 
) {
    output_folder <- file.path(output_folder, run_name)
    dir.create(output_folder, recursive = T)
    fasta_path_new <- file.path(output_folder, basename(fasta_path))
    file.copy(fasta_path, fasta_path_new, overwrite = T)
    cmd.cd <- paste0("cd ", output_folder)
    cmd.iqtree <- paste0(
        iqtree_exe,
        " -s '", 
        basename(fasta_path),
        "' -st DNA -m MF -pre '", 
        run_name,
        "' --redo"
    )
    cmd.file <- file.path(output_folder, paste0(run_name, "_modelTest.sh"))
    write(cmd.cd, cmd.file)
    write(cmd.iqtree, cmd.file, append = T)
    system(paste0("sh ", cmd.file))
    return(output_folder)
}

#' Exclude Sequences from an Alignment by Filtering Metadata
#' 
#' @description
#' Filters sequences in a `DNAbin` object whose `INSDSeq_primary-accession` matches metadata rows
#' matching `pattern` in `field`, optionally retaining a random subset of matched sequences.
#' 
#' @param aln A named `DNAbin` alignment object.
#' @param field Character. Column name in `metadata` to match against `pattern`.
#' @param pattern Character. Regular expression pattern; matching records are selected for exclusion.
#' @param retain Numeric or integer. Number of matching sequences to randomly retain rather than
#'   exclude. Default is `0`.
#' @param seed Integer or `NULL`. Optional random seed passed to [set.seed()] when `retain != 0`.
#' @param metadata A `data.frame` containing `INSDSeq_primary-accession` and `field`. Defaults to
#'   `zhutilsr::db_pull("metadata.Sequence.NCBI", silent = T)`.
#'
#' @return A filtered `DNAbin` alignment object.
#' @export
exclude_by_meta <- function(aln, field, pattern, retain = 0, seed = NULL, metadata = zhutilsr::db_pull("metadata.Sequence.NCBI", silent = T)) {
    exclude.meta <- metadata %>% 
        dplyr::filter(stringr::str_detect(.data[[field]], pattern)) %>% 
        dplyr::filter(`INSDSeq_primary-accession` %in% names(aln))
    if (retain != 0) {
        if (!is.null(seed)) {
            set.seed(seed)
        }
        if (nrow(exclude.meta) < retain) {
            avlb <- nrow(exclude.meta)
            cli::cli_alert_warning("Only {avlb} sequence matching exclusion criteria, but `retain` was set to {retain}, retaining all.")
            return(aln)
        }
        exclude.meta <- exclude.meta %>%
            dplyr::slice(-sample(1:n(), retain))
    }
    include.index <- is.na(match(names(aln), exclude.meta$`INSDSeq_primary-accession`))
    aln_reduced <- aln[include.index]
    return(aln_reduced)
}

#' Split a Concatenated Alignment Back into Single-Locus FASTA Files
#' 
#' @description
#' Slices a concatenated `DNAbin` alignment matrix by locus lengths, drops taxa that are
#' completely missing/ambiguous in a given locus, and writes `reextracted_<locus>.fasta` files.
#' 
#' @param alignment A `DNAbin` alignment matrix.
#' @param loci_name Character vector. Names of each locus.
#' @param loci_length Numeric or integer vector. Column length of each locus in `alignment`.
#' @param output_folder Character. Directory where re-extracted FASTA files are written.
#'
#' @return Character vector of output FASTA file paths.
#' @seealso [concatenate_alignment()]
#' @export
split_concat_alignment <- function(
    alignment,
    loci_name,
    loci_length,
    output_folder
) {
    partition <- data.frame(
        name = loci_name,
        length = loci_length
    ) %>%
        dplyr::mutate(
            end = cumsum(length),
            start = dplyr::lag(end, default = 0)+1
        )

    paths <- purrr::map_vec(1:length(loci_name), \(i){
        alignment.subset <- alignment[,partition[i,]$start:partition[i,]$end]

        # drop empty taxa
        char_matrix <- as.character(alignment.subset)
        all_missing <- purrr::map_lgl(1:nrow(char_matrix), \(i){
            all(char_matrix[i,] %in% c("-", "N", "n", "?"))
        })

        alignment.active <- alignment.subset[!all_missing, ]

        path <- file.path(output_folder, paste0("reextracted_", loci_name[[i]], ".fasta"))
        ape::write.FASTA(alignment.active, path)
        return(path)
    })
    return(paths)
}

#' Concatenate Multiple Single-Locus Alignments into a Multi-Locus Alignment
#' 
#' @description
#' Reads single-locus FASTA alignments, optionally applies metadata filtering via [exclude_by_meta()],
#' maps accession/sequence identifiers to organism labels using `sequence.map`, filters taxa by
#' locus availability, writes the concatenated alignment and per-locus subsets, and returns summary metadata.
#' 
#' @param fasta_path Character vector. Paths to single-locus FASTA alignment files in concatenation order.
#' @param names.alignments Character vector. Locus names matching `fasta_path` in length and order.
#' @param sequence.map A `data.frame` mapping sequence/accession IDs to organism identifiers.
#' @param identifier Character. Column name in `sequence.map` providing the organism/taxon label.
#' @param accs_col Character vector. Column names in `sequence.map` (one per locus) holding
#'   accession numbers or sequence names to match against FASTA headers.
#' @param include_strategy Character. Taxon inclusion rule across `include_strategy_loci`: `"all"`
#'   (default) or `"any"`.
#' @param include_strategy_loci Character vector. Locus names checked under `include_strategy`.
#' @param include_by Argument accepted in signature (currently unused in function body).
#' @param output_folder Character. Directory for output alignment files.
#' @param run_name Character or `NULL`. Optional suffix used in output filename (`concat_<run_name>.nexus`).
#' @param exclude_options List or `NULL`. Argument list (excluding `aln`) passed to [exclude_by_meta()],
#'   or a list of argument lists for sequential filtering steps. Default is `NULL`.
#' 
#' @return A named list containing:
#'   \describe{
#'     \item{`alignment`}{The concatenated `DNAbin` alignment matrix.}
#'     \item{`concat_fasta_path`}{Path to the written concatenated alignment file.}
#'     \item{`loci_fasta_path`}{Character vector of paths to per-locus re-extracted FASTA files.}
#'     \item{`taxa`}{Character vector of included taxon labels.}
#'     \item{`loci_parition`}{A `data.frame` of locus `name` and `length`.}
#'     \item{`sequence_composition`}{A `data.frame` indicating per-locus sequence presence for included taxa.}
#'   }
#' @seealso [exclude_by_meta()], [split_concat_alignment()]
#' @export
concatenate_alignment <- function(
    fasta_path, names.alignments, sequence.map, identifier, accs_col, 
    include_strategy = "all", include_strategy_loci, include_by, 
    output_folder, run_name = NULL, exclude_options = NULL
) {
    alignments.ls <- purrr::map(fasta_path, ~ape::read.FASTA(.x))
    
    if (purrr::pluck_depth(exclude_options) == 3) {
        alignments.ls <- purrr::reduce(exclude_options, .init = alignments.ls, .f = function(aln.ls, args) {
            aln.ls %>% purrr::map(function(aln) {
                rlang::exec(exclude_by_meta, aln = aln, !!!args)
            })
        })
    } else if (purrr::pluck_depth(exclude_options) == 2) {
        alignments.ls <- alignments.ls %>% purrr::map(function(aln) {
            rlang::exec(exclude_by_meta, aln = aln, !!!exclude_options)
        })
    }
    
    bp.alignments <- purrr::map_vec(alignments.ls, function(x) length(x[[1]]))
    names.seqs <- purrr::map(alignments.ls, ~names(.x))
    names(names.seqs) <- names.alignments
    
    map.present <- purrr::map_dfr(1:length(names.alignments), function(i) {
        sequence.map %>% dplyr::filter(.data[[accs_col[i]]] %in% names.seqs[[names.alignments[i]]])
    }) %>% dplyr::distinct()
    
    concat.seq.ls <- purrr::map(1:nrow(map.present), function(i) {
        org_label <- map.present[[identifier]][i] # Renamed to prevent shadowing the 'identifier' arg
        
        seqpair <- purrr::map(1:length(names.alignments), function(gi) {
            accNo <- map.present[[accs_col[gi]]][i]
            
            if (!is.na(accNo)) {
                if (!accNo %in% names.seqs[[gi]]) {
                  seq <- ape::as.DNAbin(list(identifier = rep("N", bp.alignments[gi])))
                  names(seq) <- org_label
                  seqs.available <- FALSE
                } else {
                  seq <- alignments.ls[[gi]][which(names.seqs[[gi]] == accNo)]
                  names(seq) <- org_label
                  seqs.available <- TRUE
                }
            } else {
                seq <- ape::as.DNAbin(list(identifier = rep("N", bp.alignments[gi])))
                names(seq) <- org_label
                seqs.available <- FALSE
            }
            return(list(seq = seq, seqs.available = seqs.available))
        })
        
        seqs.available <- seqpair %>% purrr::map_vec(~.x$seqs.available)
        concat.seq <- seqpair %>% 
            purrr::map(~.x$seq) %>% 
            purrr::map(~ape::as.matrix.DNAbin(.x)) %>% 
            purrr::reduce(~cbind(.x, .y))
        
        return(list(concat.seq = concat.seq, seqs.available = seqs.available))
    })
    
    concat.alignment <- do.call(rbind, rlist::list.filter(concat.seq.ls %>% purrr::map(~.x$concat.seq), !is.null(.)))
    
    # Cleaner construction of the boolean comparison frame
    concat.seq.comp <- purrr::map_dfr(concat.seq.ls, function(x) {
        df <- as.data.frame(as.list(x$seqs.available))
        colnames(df) <- names.alignments
        return(df)
    }) %>% dplyr::bind_cols(c_organism_label = map.present[[identifier]])
    
    # Filtering logic (using robust TRUE evaluation syntax)
    if (include_strategy == "all") {
        include.taxa <- concat.seq.comp %>% 
            dplyr::filter(dplyr::if_all(dplyr::all_of(include_strategy_loci), ~ .x == TRUE))
    } else if (include_strategy == "any") {
        include.taxa <- concat.seq.comp %>% 
            dplyr::filter(dplyr::if_any(dplyr::all_of(include_strategy_loci), ~ .x == TRUE))
    } else {
        cli::cli_abort("{.var include_strategy} must be either `all`, `any`, or `when`, not {include_strategy}.")
    }
    
    # Safety Catch: Trap 0-row matrices gracefully before it crashes downstream functions
    if (nrow(include.taxa) == 0) {
        cli::cli_abort(c(
            "No taxa left after filtering.",
            "x" = "Your `include_strategy` required {include_strategy_loci}, but no sequences successfully matched between your `sequence.map` and the FASTA headers for this locus."
        ))
    }
    
    # Bug Fix: Ensure drop = FALSE so 1-row returns don't accidentally coerce into vectors
    concat.alignment <- concat.alignment[dimnames(concat.alignment)[[1]] %in% include.taxa$c_organism_label, , drop = FALSE]
    
    if (!is.null(run_name)) {
        concat.path <- file.path(output_folder, paste0("concat_", run_name, ".nexus"))
    } else {
        concat.path <- file.path(output_folder, "concat.nexus")
    }
    
    # Bug Fix: ensure dir.create targets the folder, not the file itself
    dir.create(dirname(concat.path), recursive = TRUE, showWarnings = FALSE)
    
    ape::write.FASTA(concat.alignment, concat.path)
    alnbyhand.path <- split_concat_alignment(concat.alignment, names.alignments, bp.alignments, output_folder)
    
    res <- list(
        alignment = concat.alignment, 
        concat_fasta_path = concat.path, 
        loci_fasta_path = alnbyhand.path, 
        taxa = dimnames(concat.alignment)[[1]], 
        loci_parition = data.frame(name = names.alignments, length = bp.alignments), 
        sequence_composition = concat.seq.comp %>% dplyr::filter(c_organism_label %in% dimnames(concat.alignment)[[1]])
    )
    
    return(res)
}

#' Summarize Alignment Dimensions and Taxa from a FASTA or NEXUS File
#'
#' @param path Character. Path to a `.fasta` or `.nexus` alignment file.
#'
#' @return A named list with elements `ntaxa` (integer), `width` (integer), and `taxa` (character vector).
#' @export
summarize_alignment <- function(path){
    if (stringr::str_detect(path, "\\.nexus$")) {
        aln <- ape::read.nexus.data(path)
    } else if (stringr::str_detect(path, "\\.fasta$")) {
        aln <- ape::read.FASTA(path)
    } else {
        cli::cli_abort("Path is neither a fasta file nor a nexus file.")
    }

    cli::cli_alert_info("Alignment read from {path}")
    cat("\n")
    cli::cli_text("Number of taxa: {length(aln)}\n")
    cli::cli_text("Alignment width: {length(aln[[1]])} bp\n")
    cat("\n")

    return(list(
        ntaxa = length(aln),
        width = length(aln[[1]]),
        taxa = names(aln)
    ))
}

#' Merge Multiple FASTA Files and Deduplicate Sequence Names
#'
#' @param ... Character paths to input FASTA files.
#' @param output_file Character. Path to the merged output FASTA file.
#' @param overwrite Logical. Whether to overwrite `output_file` if it already exists.
#'   Default is `FALSE`.
#'
#' @return Invisibly returns the result of [ape::write.FASTA()].
#' @export
merge_fasta <- function(..., output_file, overwrite = FALSE) {
    combined <- list(...) %>% purrr::map(~ape::read.FASTA(.x)) %>% purrr::reduce(\(x,y) c(x, y))
    
    dir.create(dirname(output_file))
    if (file.exists(output_file) && !overwrite) {
        cli::cli_abort(sprintf("Output file `%s` already exists.", output_file))
    }

    dups <- duplicated(names(combined))
    if (any(dups)) {
        cli::cli_alert_warning("Sequences {paste(names(combined)[dups])} are duplicated. Removed duplicates. ")
        combined <- combined[!dups]
    }
    ape::write.FASTA(combined, output_file)
}

#' Convert a `DNAbin` Object to a `Biostrings::DNAStringSet`
#'
#' @param DNAbin A `DNAbin` object.
#'
#' @return A `Biostrings::DNAStringSet` object.
#' @noRd
.DNAbin2DNAStringSet <- function(DNAbin) {
    DNAbin %>% as.character %>% lapply(., paste0, collapse = "") %>% unlist %>% Biostrings::DNAStringSet
}