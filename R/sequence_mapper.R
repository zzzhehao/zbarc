
#' Create a Summary Table Mapping Sequence Label/Accession Number with Vouchered Animals.
#'
#' @description
#' This will summarize the sequence labels in the way that the sequnces originated from the same vouchered animals could be linked together, which is essential for concatenate multilocus alignment.
#'
#' @return data.frame, basically a wide table of imported metadata data.frame, with every specimen (identified by \code{col_id_specimen}) as a row and every gene (identified by \code{col_gene}) as a column. Values are filled with \code{col_id_sequence}.
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


#' Generate Sequence Metadata LUT
#'
#' @import dplyr
#' @import purrr
#' @import tidyr
#' @export
generate_sequence_LUT <- function() {
    specmeta <- zhutilsr::db_pull("metadata.Specimen.Haploniscidae")
    sequence.map <- zhutilsr::db_pull("sequence.map", F, T)
    stmeta <- zhutilsr::db_pull("metadata.Station")

    # Construct c_organims_id and c_organism_label to match with sequence.map
    # specmeta.label <- specmeta %>%
    #     dplyr::select(c("DZMB2HH", "voucher", "gensp_morpho_ZH")) %>%
    #     dplyr::filter(!is.na(voucher)) %>%
    #     dplyr::mutate(
    #         c_organism_id = paste0("ZHH", stringr::str_pad(as.character(voucher), 3, "left", "0")),
    #         c_organism_label = paste(gensp_morpho_ZH, DZMB2HH, voucher, sep = "_"),
    #         .keep = "none")

    # match sequence.map
    sequence.map.LUT <- sequence.map %>%
        # rows_update(specmeta.label, by = "c_organism_id") %>%
        # pivot longer
        tidyr::pivot_longer(
            tidyselect::starts_with("c_gene_"),
            names_to = "gene",
            values_to = "identifier"
        ) %>%
        # choose desired columns
        dplyr::select(c("identifier", "c_organism_id", "c_organism_label"))

    # Extract IDivA subset
    sequence.map.LUT.IDivA <- sequence.map.LUT %>%
        dplyr::filter(stringr::str_detect(identifier, "[0-9]{3}_.{3}$"))

    # add locality label to ZHH seq
    sequence.map.LUT.IDivA_ZH <- sequence.map.LUT.IDivA %>%
        dplyr::filter(stringr::str_detect(c_organism_id, "^ZHH")) %>%
        dplyr::mutate(
            # identifier = paste0("ZHH", identifier),
            voucher = c_organism_id %>% gsub("ZHH", "", .) %>% as.numeric()
        ) %>%
        dplyr::left_join(
            specmeta %>% dplyr::select(c("voucher", "station")),
            by = "voucher"
        ) %>%
        dplyr::left_join(
            stmeta %>% dplyr::select(c("station", "loc_abbr")),
            by = "station"
        ) %>%
        dplyr::mutate(
            c_organism_label = paste(c_organism_label, loc_abbr, sep = "_")
        ) %>%
        dplyr::select(-c("voucher", "station", "loc_abbr"))

    # multiplies IDivA subset for two voucher prefixes
    sequence.map.LUT.merged <- list(
        sequence.map.LUT %>%
            dplyr::filter(stringr::str_detect(identifier, "^[A-Z]{3}[0-9]{3}_.{3}$", T)),
        # sequence.map.LUT.IDivA %>% dplyr::mutate(identifier = paste0("VPS", identifier)),
        sequence.map.LUT.IDivA %>% dplyr::filter(stringr::str_detect(c_organism_id, "^VPS")),
        sequence.map.LUT.IDivA_ZH
    ) %>%
        purrr::reduce(dplyr::bind_rows)
    # dplyr::filter(!is.na(identifier)) %>%
    # dplyr::mutate(c_organism_label = dplyr::case_when(stringr::str_detect(identifier, "^[A-Z]{3}[0-9]{3}_") ~ paste(c_organism_label, gsub("_.{3}$", "", identifier), sep = "_"), .default = c_organism_label))
    return(sequence.map.LUT.merged)
}


generate_orglab_LUT <- function(tip.taxa) {
    seqmap <- zhutilsr::db_pull("sequence.map")
    seqmap <- seqmap %>%
        dplyr::mutate(c_organism_label = as.numeric(c_organism_label)) %>%
        dplyr::filter(!is.na(c_organism_label)) %>%
        dplyr::select(c_organism_label, c_organism_id)
    seqmap %>%
        dplyr::filter(
            c_organism_label %in%
                tip.taxa &
                is.na(as.numeric(seqmap$c_organism_id))
        )
}
