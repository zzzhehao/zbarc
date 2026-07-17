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
    zhutilsr::.dir_check(output_dir, overwrite)

    # use absolute path bc -o flag in ASAP is broken (prob so as in ABGD)
    output_dir_abs <- normalizePath(output_dir, mustWork = TRUE)
    exe <- normalizePath(exe, mustWork = TRUE)
    d <- paste("-d", dist)
    i <- shQuote(normalizePath(input, mustWork = TRUE))

    # change wd temporarily bc same reason and res.cvs file is generated to R wd root
    old_wd <- setwd(output_dir_abs)
    on.exit(setwd(old_wd), add = TRUE)

    args <- c("-a", d, i, c(...))

    stdout.file <- file.path(output_dir, "console.txt")
    errmsg <- tempfile("errmsg", fileext = ".txt")
    on.exit(unlink(errmsg), add = TRUE)

    status_code <- system2(
        command = exe,
        args = args,
        # stdout = stdout.file,
        stderr = errmsg       
    )

    if (status_code != 0) {
        # Read the error log back into R to show the user
        err_msg <- paste(readLines(errmsg), collapse = "\n")
        stop("ASAP failed with exit status: ", status_code, 
            "\nError log:\n", err_msg)
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
#' @return A [asap] class object. 
#' @export
asap_evaluate <- function(
    dir
) {
    files <- list.files(dir, full.names = T, all.files = T)
    file.res <- files[stringr::str_detect(files, "\\.res\\.cvs$")][1]

    # overview
    res <- tibble::tibble(read.table(file.res, sep = "\t", header = T))
    part.best <- res[res$Asap.score == min(res$Asap.score),]$`Partition.rank` %>% as.integer()

    # best partition
    part.best.report <- suppressWarnings(readLines(files[stringr::str_detect(files, sprintf("Partition_%d\\.txt$", part.best))][1]))
    part.best.sc <- part.best.report[stringr::str_detect(part.best.report, "Asap-Score")] %>% 
        stringr::str_extract("(?<=Asap-Score: ).+$") %>% 
        as.numeric()
    part.best.p <- part.best.report[stringr::str_detect(part.best.report, "Proba")] %>% 
        stringr::str_extract("(?<=Proba: ).+$") %>% 
        as.numeric()
    part.best.sp <- part.best.report[stringr::str_detect(part.best.report, "Nb subsets")] %>% 
        stringr::str_extract("(?<=^Nb subsets with recursion:).+(?=\\(.)") %>% 
        as.integer()
    part.best.res <- read.table(files[stringr::str_detect(files, sprintf("Partition_%d\\.csv$", part.best))][1], sep = ",", strip.white = TRUE) %>% 
        `colnames<-`(c("identifier", "otu")) %>% 
        tibble::tibble()

    # dist matrix
    part.dist.mat <- read.table(files[stringr::str_detect(files, "_distmat\\.txt$")][1], sep = " ", skip = 1) %>% 
        tibble::column_to_rownames(var = "V1") %>% 
        `colnames<-`(rownames(.))


    res.obj <- asap(
        res,
        part.best,
        part.best.sc,
        part.best.p,
        part.best.sp,
        part.best.res,
        part.dist.mat
    )

    # report
    cli::cli_alert_info(
" ====== ASAP result ======
Directory read: {dir}

The best partition was rank {part.best} with ASAP-score {part.best.sc} and p-value {part.best.p}. {part.best.sp} OTUs were identified. 

Use `.@otu` to access OTU assignment to specimens. "
    )

    return(res.obj)
}