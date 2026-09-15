#' @import S7
NULL

#' Performing ASAP
#' @param input Character. A path to aligned fasta file as input.
#' @param name description
#' @param dist Numeric. Method for calculating genetic distance. 0: Kimura-2P, 1: Jukes-Cantor, 2: Tamura Nei, 3: simple p-distance. Defualt to 3. 
#' @param output_dir Character. A path to output directory. 
#' @param exe Character. A path to ASAP excutable file.
#' @return A path to the output directory. 
#' @export
asap_execute <- function(
    input, 
    output_dir, 
    exe, 
    dist = 3, 
    overwrite = FALSE, 
    ...
) {
    # Suppress the "already exists" warning and allow recursive creation
    dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
    
    output_dir_abs <- normalizePath(output_dir, mustWork = TRUE)
    exe <- normalizePath(exe, mustWork = TRUE)
    
    # 1. REMOVED shQuote() - system2 handles spaces safely on its own
    i <- normalizePath(input, mustWork = TRUE)
    
    old_wd <- setwd(output_dir_abs)
    on.exit(setwd(old_wd), add = TRUE)
    
    # 2. Separated "-d" and dist into distinct arguments
    args <- c("-a", "-d", as.character(dist), i, ...)
    
    errmsg <- tempfile("errmsg", fileext = ".txt")
    
    # Ensure temporary file is cleaned up after execution
    on.exit(unlink(errmsg), add = TRUE)
    
    status_code <- system2(command = exe, args = args, stderr = errmsg)
    
    if (status_code != 0) {
        err_msg <- paste(readLines(errmsg), collapse = "\n")
        stop("ASAP failed with exit status: ", status_code, "\nError log:\n", err_msg)
    }
    
    return(output_dir)
}

#' ASAP result
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

#' Evaluates ASAP output
#' @param dir A path to ASAP result directory.
#' @param part Integer. Number of the best partitions to evaluate. Default to 3. 
#' @return A list of [asap] class objects. 
#' @export
asap_evaluate <- function(
    dir,
    part = 3
) {
    files <- list.files(dir, full.names = T, all.files = T)
    file.res <- files[stringr::str_detect(files, "\\.res\\.csv$")][1]

    # overview
    res <- tibble::tibble(read.table(file.res, sep = "\t", header = T))
    part.best <- res %>% 
        dplyr::distinct(Asap.score, .keep_all = T) %>% 
        dplyr::slice_head(n = part)
    part.best.rank <- part.best %>% 
        dplyr::pull(Partition.rank)

    res.ls <- map(part.best.rank, ~{
        part.best.report <- suppressWarnings(readLines(files[stringr::str_detect(files, sprintf("Partition_%d\\.txt$", .x))][1]))
        part.best.sc <- part.best.report[stringr::str_detect(part.best.report, "Asap-Score")] %>% 
            stringr::str_extract("(?<=Asap-Score: ).+$") %>% 
            as.numeric()
        part.best.p <- part.best.report[stringr::str_detect(part.best.report, "Proba")] %>% 
            stringr::str_extract("(?<=Proba: ).+$") %>% 
            as.numeric()
        part.best.sp <- part.best.report[stringr::str_detect(part.best.report, "Nb subsets")] %>% 
            stringr::str_extract("(?<=^Nb subsets with recursion:).+(?=\\(.)") %>% 
            as.integer()
        part.best.res <- read.table(files[stringr::str_detect(files, sprintf("Partition_%d\\.csv$", .x))][1], sep = ",", strip.white = TRUE) %>% 
            `colnames<-`(c("identifier", "otu")) %>% 
            tibble::tibble()
    
        # dist matrix
        part.dist.mat <- read.table(files[stringr::str_detect(files, "_distmat\\.txt$")][1], sep = " ", skip = 1) %>% 
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