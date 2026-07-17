#' Create a Summary Table Mapping Sequence Label/Accession Number with Vouchered Animals.
#'
#' @description
#' This will summarize the sequence labels in the way that the sequnces originated from the same vouchered animals could be linked together, which is essential for concatenate multilocus alignment.
#'
#' @return Nothing. A data.frame will be written into the database.
#' @param regenerate logical. Whether to overwrite existing table in the database. Otherwise only the rows with vouchered animal not yet in the database will be added.
#' @import DBI
#' @import dplyr
#' @import RSQLite
#' @import tidyr
#' @import stringr
update_sequence_map <- function(regenerate = F) {
    # Generate wide table
    metadata.seq <- zhutilsr::db_pull("metadata.Sequence.NCBI", T, T)
    sequence.map.ncbi <- metadata.seq %>%
        dplyr::filter(!is.na(c_gene)) %>%
        tidyr::pivot_wider(
            id_cols = c_organism_id,
            names_from = c_gene,
            names_prefix = "c_gene_",
            values_from = `INSDSeq_primary-accession`
        )

    # Combine with vps names
    allvps <- zhutilsr::db_pull("metadata.Specimen.Haploniscidae") %>%
        dplyr::pull(voucher) %>%
        sort() %>%
        as.character() %>%
        stringr::str_pad(3, "left", "0")
    noprefix.vps <- data.frame(c_organism_id = allvps)
    vps.map <- dplyr::bind_rows(
        dplyr::mutate(noprefix.vps, c_organism_id = paste0("ZHH", c_organism_id)),
        dplyr::mutate(noprefix.vps, c_organism_id = paste0("VPS", c_organism_id))
    ) %>%
        dplyr::mutate(
            c_gene_COI = paste0(c_organism_id, "_COI"),
            c_gene_16S = paste0(c_organism_id, "_16S"),
            c_gene_18S = paste0(c_organism_id, "_18S"),
            c_gene_28S = paste0(c_organism_id, "_28S"),
        )

    sequence.map <- dplyr::bind_rows(sequence.map.ncbi, vps.map)
    metadata.spec <- zhutilsr::db_pull("metadata.Specimen.Haploniscidae") %>%
        dplyr::mutate(
            label_genetics = paste(gensp_morpho_ZH, DZMB2HH, sep = "_") %>%
                gsub("\\.", "", .) %>%
                gsub(" ", "_", .)
        )
    sequence.map <- sequence.map %>%
        dplyr::mutate(
            id = 1:nrow(sequence.map),
            c_organism_label = c_organism_id %>%
                gsub(" ", "_", .) %>%
                gsub("\\.", "", .) %>%
                gsub(":", "-", .) %>%
                gsub("^Haploniscidae_sp_[A-Z]{3,5}[0-9]{3,4}-[0-9]{2}_", "", .), # CCZ batch with ultra long name
            c_organism_label = dplyr::case_when(
                stringr::str_detect(c_organism_id, "^[A-Z]{3}[0-9]{3}$") ~ {
                    input_key <- stringr::str_sub(c_organism_id, 4, 6) %>% as.numeric()
                    purrr::map_vec(
                        input_key,
                        ~ zhutilsr::map_value(.x, metadata.spec, voucher, label_genetics)
                    ) %>%
                        paste0(., "_", c_organism_id)
                },
                .default = c_organism_label
            )
        )

    BATJRdb <- zhutilsr::.dbconn()
    if (!"sequence.map" %in% DBI::dbListTables(BATJRdb)) {
        # Initialize
        print("No sequence map found, initializing ... ")
        DBI::dbWriteTable(BATJRdb, "sequence.map", sequence.map)
        DBI::dbDisconnect(BATJRdb)
        return()
    } else {
        if (regenerate) {
            print("Regenerating sequence.map table ... ")
            DBI::dbWriteTable(BATJRdb, "sequence.map", sequence.map, overwrite = T)
            DBI::dbDisconnect(BATJRdb)
            return()
        }
        sequence.map.registered <- zhutilsr::db_pull("sequence.map", F, F)

        sequence.map.new <- sequence.map %>%
            dplyr::filter(
                !c_organism_id %in% sequence.map.registered$c_organism_id
            )
        sequence.map.updated <- dplyr::bind_rows(
            sequence.map.registered,
            sequence.map.new
        )
        DBI::dbWriteTable(
            BATJRdb,
            "sequence.map",
            sequence.map.updated,
            overwrite = T
        )
        zhutilsr::db_sign(
            "sequence.map",
            "Append",
            "Sequence map (accession number of each specimen voucher) has been updated.",
            Sys.Date() %>% gsub("-", "", .) %>% paste0("sequenceMap")
        )
        print("Sequence map has been successfully updated.")
        DBI::dbDisconnect(BATJRdb)
        return()
    }
}


#' Generate Sequence Metadata LUT
#'
#' @import dplyr
#' @import purrr
#' @import tidyr
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
