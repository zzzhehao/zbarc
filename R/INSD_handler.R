#' Extract INSD Metadata from an XML File Downloaded from NCBI GenBank
#'
#' @param xml Character. File path to an INSD XML file.
#'
#' @family insd
#' @keywords internal
#' @return A `data.frame` of flattened sequence, feature qualifier, and reference metadata.
.read_insd <- function(xml) {
    suppressMessages({
        ncbi.xml <- xml2::read_xml(xml)
        ncbi.xml.parsed <- XML::xmlParse(ncbi.xml)
        ncbi.ls <- XML::xmlToList(ncbi.xml.parsed)

        feature.table <- purrr::map(ncbi.ls, \(seq) {
            ele.ls <- seq$`INSDSeq_feature-table`
            
            # Map over features directly, checking for missing qualifiers safely
            purrr::map(ele.ls, \(feat) {
                key <- feat$INSDFeature_key
                quals <- feat$INSDFeature_quals
                
                # Safe escape if the feature has no qualifiers
                if (is.null(quals)) return(NULL)
                
                purrr::map(quals, \(qua.entry) {
                    # Handle edge cases where a qualifier exists but has no value
                    val <- qua.entry$INSDQualifier_value
                    if (is.null(val)) val <- NA
                    
                    list(val) %>%
                        `names<-`(paste(
                            key,
                            qua.entry$INSDQualifier_name,
                            sep = "_"
                        ))
                }) %>%
                    purrr::flatten()
            }) %>%
                purrr::flatten()
        }) %>%
            dplyr::bind_rows()

        ref.table <- purrr::map(ncbi.ls, \(seq) {
            ref.ls <- seq$INSDSeq_references
            if (length(ref.ls) > 1) {
                # if there are more than one reference, only one of them should be the final reference.
                ref.entry <- ref.ls %>%
                    rlist::list.filter(stringr::str_detect(
                        INSDReference_journal,
                        "Submitted"
                    )) %>%
                    .[1]
                if (
                    # if there is no submitted reference, or the submitted reference is the direct submission before manuscript publication, then just take one, as the direct submission will override the publication title.
                    any(c(
                        is.null(unlist(ref.entry)),
                        ref.entry$INSDReference$INSDReference_title ==
                            "Direct Submission"
                    ))
                ) {
                    ref.entry <- ref.ls %>%
                        rlist::list.filter(
                            INSDReference_reference ==
                                ref.ls %>%
                                    rlist::list.select(INSDReference_reference) %>%
                                    .[[1]]
                        )
                }
            } else {
                # there is only one reference
                ref.entry <- ref.ls %>%
                    rlist::list.filter(
                        INSDReference_reference ==
                            ref.ls %>%
                                rlist::list.select(INSDReference_reference) %>%
                                .[[1]]
                    )
            }
            data.frame(
                Ref_authors = paste(
                    ref.entry$INSDReference$INSDReference_authors,
                    collapse = ";"
                ),
                Ref_title = ref.entry$INSDReference$INSDReference_title,
                Ref_journal = ref.entry$INSDReference$INSDReference_journal
            ) %>%
                purrr::flatten()
        }) %>%
            dplyr::bind_rows()

        primary.info <- ncbi.ls %>%
            rlist::list.select(
                `INSDSeq_primary-accession`,
                `INSDSeq_sequence`,
                `INSDSeq_length`,
                `INSDSeq_definition`,
                `INSDSeq_organism`,
                `INSDSeq_taxonomy`
            ) %>%
            dplyr::bind_rows()

        INSDMetadata <-
            dplyr::bind_cols(primary.info, feature.table, ref.table) %>%
            dplyr::rename(
                "INSDSeq_primary-accession" = "`INSDSeq_primary-accession`"
            ) %>%
            dplyr::select(-dplyr::contains("db_xref"))
    })
    return(INSDMetadata)
}

#' Load Sequences from NCBI GenBank with Metadata from INSD XML Files
#'
#' @param path Character vector. Path to a directory or to XML files. If a directory path is
#'   provided, matching XML files are loaded.
#' @param recursive Logical. When `path` is a directory, whether to search for XML files
#'   recursively. Default is `TRUE`.
#' @param regex Character or `NULL`. Optional regular expression passed to `pattern` in
#'   [list.files()] when `path` is a directory.
#'
#' @return A `data.frame` containing parsed INSD fields plus three derived columns:
#' \describe{
#'   \item{`zseq.voucher`}{Specimen voucher extracted from `source_specimen_voucher` or `source_isolate`.}
#'   \item{`zseq.organism_id`}{Specimen identifier derived from `source_organism` and `zseq.voucher`.}
#'   \item{`zseq.gene`}{Gene/locus label detected from `INSDSeq_definition` (`cytochrome`, `18S`, `28S`, `16S`, or fallback `INSDSeq_definition`).}
#' }
#' @family insd
#' @export
load_insd <- function(
    path,
    recursive = TRUE,
    regex = NULL
) {
    if (zhutilsr::is_dir(path)) {
        if (length(path) > 1) {cli::cli_abort("If `path` is directory, it should be length of 1, not {length(path)}.")}
        files <- list.files(path, pattern = regex, recursive = recursive, full.names = T)
    } else if (zhutilsr::is_file(path)) {
        files <- path
    }

    # double check: path should be .xml
    INSD.files <- stringr::str_subset(files, "\\.xml$")
    notxml <- !files %in% INSD.files
    if (any(notxml)) {
        cli::cli_alert_warning("{files[notxml]} are not .xml files.")
    }
    if (length(INSD.files) == 0) {
        cli::cli_abort("No XML files found.")
    }

    extract_voucher <- function(metadata.seq) {
        labels <- dplyr::tibble(
            source_specimen_voucher = character(),
            source_isolate = character(),
            source_organism = character()
            ) %>%
            dplyr::bind_rows(metadata.seq) %>%
            dplyr::mutate(
                source_specimen_voucher = dplyr::na_if(source_specimen_voucher, "NA"),
                zseq.voucher = dplyr::coalesce(
                    source_specimen_voucher,
                    source_isolate
                ),
                zseq.organism_id = dplyr::case_when(
                    is.na(zseq.voucher) ~ source_organism, # prevent literal NA for those don't have any specimen zseq.voucher info, overides next case, which includes NA cases
                    stringr::str_detect(
                        source_organism,
                        paste0("\\b", zseq.voucher, "\\b"),
                        T
                    ) ~ paste(source_organism, zseq.voucher),
                    .default = source_organism
                )
            ) %>%
            dplyr::select(c(
                "INSDSeq_primary-accession",
                "zseq.voucher",
                "zseq.organism_id"
            ))
        dplyr::left_join(metadata.seq, labels, by = "INSDSeq_primary-accession")
    }

    extract_gene <- function(metadata.seq) {
        gene_ex <- metadata.seq %>%
            dplyr::mutate(
                zseq.gene = dplyr::case_when(
                    stringr::str_detect(INSDSeq_definition, "\\bcytochrome\\b") ~ "cytochrome",
                    stringr::str_detect(INSDSeq_definition, "\\b18S\\b") ~ "18S",
                    stringr::str_detect(INSDSeq_definition, "\\b28S\\b") ~ "28S",
                    stringr::str_detect(INSDSeq_definition, "\\b16S\\b") ~ "16S",
                    .default = INSDSeq_definition
                )
            ) %>%
            dplyr::select(c("INSDSeq_primary-accession", "zseq.gene"))
        dplyr::left_join(metadata.seq, gene_ex, by = "INSDSeq_primary-accession")
    }

    paste0(
        "Loading following XML files: \n\n",
        paste(INSD.files, collapse = "\n"),
        collapse = ""
    ) %>%
        cat()

    tbl.INSD.raw <- purrr::map(INSD.files, \(xml) {
        .read_insd(xml)
    }) %>%
        dplyr::bind_rows()

    # Filtering, extracting steps as documented in log 0829.qmd
    tbl.INSD <- tbl.INSD.raw %>%
        # filter_c() %>%
        extract_voucher() %>%
        extract_gene()

    return(tbl.INSD)    
}