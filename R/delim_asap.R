#' @import S7
NULL

#' Run ASAP Species Delimitation
#'
#' @param input Character. Path to an aligned FASTA file used as input.
#' @param output_dir Character. Path to the output directory.
#' @param exe Character. Path to the ASAP executable file.
#' @param dist Numeric or integer. Method for calculating genetic distance: `0` = Kimura-2P,
#'   `1` = Jukes-Cantor, `2` = Tamura-Nei, `3` = simple p-distance. Default is `3`.
#' @param overwrite Logical. Whether to overwrite existing files in `output_dir`. Default is `FALSE`.
#' @param ... Additional arguments passed to the ASAP CLI executable.
#'
#' @return Character path to `output_dir`.
#' @family asap
#' @export
asap_execute <- function(
    input, 
    output_dir, 
    exe, 
    dist = 3, 
    overwrite = FALSE, 
    ...
) {
    dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
    
    output_dir_abs <- normalizePath(output_dir, mustWork = TRUE)
    exe <- normalizePath(exe, mustWork = TRUE)
    i <- normalizePath(input, mustWork = TRUE)
    
    old_wd <- setwd(output_dir_abs)
    on.exit(setwd(old_wd), add = TRUE)
    
    args <- c("-a", "-d", as.character(dist), i, ...)
    errmsg <- tempfile("errmsg", fileext = ".txt")
    on.exit(unlink(errmsg), add = TRUE)
    
    status_code <- system2(command = exe, args = args, stderr = errmsg)
    
    # 1. Catch outright crashes (Segfaults)
    if (status_code != 0) {
        err_msg <- paste(readLines(errmsg), collapse = "\n")
        stop("ASAP crashed with exit status: ", status_code, "\nError log:\n", err_msg)
    }
    
    # # 2. Catch Silent Failures (Exit 0, but no files generated)
    # expected_files <- list.files(output_dir_abs, pattern = "\\.res\\.cvs$")
    # if (length(expected_files) == 0) {
    #     err_msg <- paste(readLines(errmsg), collapse = "\n")
    #     stop("ASAP failed silently. It returned success (0), but failed to generate the expected output files. ",
    #          "This is usually caused by mathematical errors (like 0-overlap sequences) in the FASTA alignment.\nError log:\n", err_msg)
    # }
    
    return(output_dir)
}

#' ASAP Result S7 Class
#'
#' @description
#' An S7 class storing parsed ASAP partition statistics, specimen-to-OTU assignments,
#' and pairwise genetic distance matrices.
#'
#' @param partitions A `data.frame` of all evaluated ASAP partitions.
#' @param best_rank An `integer` partition rank.
#' @param best_score A `numeric` ASAP score for the partition.
#' @param best_p A `numeric` p-value (`Proba`) for the partition.
#' @param notu An `integer` number of delimited subsets/OTUs.
#' @param otu A `data.frame` mapping specimen `identifier` to `otu`.
#' @param dist.mat A pairwise distance matrix object.
#'
#' @family asap
#' @export
asap <- new_class(
    "asap",
    properties = list(
        partitions = class_data.frame,
        best_rank = class_integer,
        best_score = class_numeric,
        best_p = class_numeric,
        notu = class_integer,
        otu = class_data.frame,
        dist.mat = class_any
    )
)

#' Evaluate ASAP Output
#'
#' @param dir Character. Path to an ASAP result directory.
#' @param part Integer. Number of top partitions to evaluate. Default is `3`.
#' @param smart_filter Logical. If `TRUE`, filters partitions by group count (`NbSubset`) keeping
#'   the lowest `p.val` per group size before ranking by `Asap.score`. If `FALSE`, takes the top
#'   distinct `Asap.score` values directly. Default is `TRUE`.
#'
#' @return A list of [asap] S7 objects of length `part`.
#' @family asap
#' @export
asap_evaluate <- function(
    dir,
    part = 3,
    smart_filter = TRUE
) {
    files <- list.files(dir, full.names = T, all.files = T)
    file.res <- files[stringr::str_detect(files, "\\.res\\.cvs$")][1] # cvs is not a typo. The ASAP does produce a file with this extention. It is however a csv. It's their typo. 

    if (is.na(file.res) || !file.exists(file.res)) {
        cli::cli_abort("Could not find the ASAP results file (*.res.cvs) in directory: {dir}")
    }

    # overview
    res <- tibble::tibble(read.table(file.res, sep = "\t", header = TRUE))
    if (smart_filter) {
        # SMART MODE: Extract best p.val per group size, then rank by Asap.score
        part.best <- res %>% 
            # ASAP typically outputs the number of groups in a column named `Species`
            dplyr::group_by(NbSubset) %>% 
            dplyr::slice_min(order_by = p.val, n = 1, with_ties = FALSE) %>% 
            dplyr::ungroup() %>% 
            dplyr::arrange(Asap.score) %>% 
            dplyr::slice_head(n = part)
    } else {
        # ORIGINAL STRICT MODE: Just grab the top distinct scores
        part.best <- res %>% 
            dplyr::distinct(Asap.score, .keep_all = T) %>% 
            dplyr::slice_head(n = part)
    }
    part.best.rank <- part.best %>% 
        dplyr::pull(Partition.rank)

    res.ls <- purrr::map(part.best.rank, ~{
        # Added safety checks to ensure txt and csv files exist before reading
        txt_file <- files[stringr::str_detect(files, sprintf("Partition_%d\\.txt$", .x))][1]
        csv_file <- files[stringr::str_detect(files, sprintf("Partition_%d\\.csv$", .x))][1]
        dist_file <- files[stringr::str_detect(files, "_distmat\\.txt$")][1]
        
        if (any(is.na(c(txt_file, csv_file, dist_file)))) {
            cli::cli_abort("Missing partition or distance files for rank {.x}.")
        }

        part.best.report <- suppressWarnings(readLines(txt_file))
        
        part.best.sc <- part.best.report[stringr::str_detect(part.best.report, "Asap-Score")] %>% 
            stringr::str_extract("(?<=Asap-Score: ).+$") %>% 
            as.numeric()
            
        part.best.p <- part.best.report[stringr::str_detect(part.best.report, "Proba")] %>% 
            stringr::str_extract("(?<=Proba: ).+$") %>% 
            as.numeric()
            
        part.best.sp <- part.best.report[stringr::str_detect(part.best.report, "Nb subsets")] %>% 
            stringr::str_extract("(?<=^Nb subsets with recursion:).+(?=\\(.)") %>% 
            as.integer()
            
        part.best.res <- read.table(csv_file, sep = ",", strip.white = TRUE) %>% 
            `colnames<-`(c("identifier", "otu")) %>% 
            tibble::tibble()
    
        # dist matrix
        part.dist.mat <- read.table(dist_file, sep = " ", skip = 1) %>% 
            tibble::column_to_rownames(var = "V1") %>% 
            `colnames<-`(rownames(.))
    
        res.obj <- asap(
            res,
            .x,
            part.best.sc,
            part.best.p,
            part.best.sp,
            part.best.res,
            part.dist.mat
        )
    })

    # report
    cli::cli_alert_info(" ====== ASAP result ======\nDirectory read: {dir}\n\nFollowing partitions were evaluated:")
    print(part.best)
    cli::cli_alert_info("Use `.@otu` to access OTU assignment to specimens. ")

    return(res.ls)
}