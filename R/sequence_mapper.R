#' Create a Wide Sequence Map Linking Sequences to Specimens Across Genes
#'
#' @description
#' Reshapes sequence metadata into a wide table linking sequences from the same vouchered
#' specimen across loci, which can be used as `sequence.map` in [concatenate_alignment()].
#'
#' @param metadata.sequence A `data.frame` containing sequence-level metadata.
#' @param col_gene Unquoted column name in `metadata.sequence` identifying the gene/locus.
#' @param col_id_specimen Unquoted column name in `metadata.sequence` identifying the specimen.
#' @param col_id_sequence Unquoted column name in `metadata.sequence` identifying the sequence or
#'   accession ID.
#'
#' @return A wide `data.frame` with a `specimen` column (from `col_id_specimen`) and one column
#'   per locus (`gene_<col_gene>`) populated with values from `col_id_sequence`.
#' @family management
#' @export
generate_sequence_map <- function(
    metadata.sequence,
    col_gene,
    col_id_specimen,
    col_id_sequence
) {
    # Generate wide table
    sequence.map <- metadata.sequence %>%
        dplyr::filter(!is.na({{ col_gene }})) %>%
        tidyr::pivot_wider(
            id_cols = {{ col_id_specimen }},
            names_from = {{ col_gene }},
            names_prefix = "gene_",
            values_from = {{ col_id_sequence }}
        ) %>% 
        rename(specimen = {{ col_id_specimen }})
    return(sequence.map)
}

