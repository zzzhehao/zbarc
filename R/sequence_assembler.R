#' Assemble contigs by mapping sanger sequencing reads to a reference sequence
#' 
#' @description
#' `r lifecycle::badge("deprecated")`
#' This function is deprecated in version 0.0.1.9001 and will be removed in a future update. 
#' 
#' Assemble a set of sanger sequencing reads (ab1) by mapping them against a reference sequence. 
#' 
#' @details
#' AB1 reads are read by [sangeranalyseR::SangerRead()] with trimming options specified by \code{trim_args}. Primer sequences are removed by matching primer information with ab1 reads and trimming with [Biostrings::trimLRPatterns()]. Cleaned reads are aligned against reference one-by-one using [DECIPHER::AlignSeqs()]. The alignment is optimized with [DECIPHER::AdjustAlignment()] and the contig is produced by [DECIPHER::ConsensusSequence()].
#' 
#' 
#' @param source_folder Path to the folder containing ab1 files of the reads.
#' @param contig_name_regex A regex pattern to find ab1 files to be assembled.
#' @param primers Path to the YAML file, or a \code{data.frame} containing the primer information. The YAML file is structured as follows: 
#' \preformatted{
#' primers:
#'   - name: 18A1mod
#'     direction: forward
#'     sequence: CTGGTTGATCCTGCCAGTCATATGC
#'     spec: forward_start
#'   ...
#' }
#' The four shown properties are required as column if \code{data.frame} is provided. The primers are listed following the order of forward first to forward last, reverse first to reverse last. \code{name} should match the primer names in the ab1 files, \code{direction} decides whether a read will be reverse-complement before mapping, \code{sequence} will be removed from reads, and \code{spec} is a special field with pre-defined keywords: 
#'   \describe{
#'     \item{forward_start}{The first primer of the forward strand}
#'     \item{forward_end}{The last primer of the forward strand}
#'     \item{reverse_start}{The first primer of the reverse strand}
#'     \item{reverse_end}{The last primer of the reverse strand}
#'   }
#' @param reference A \code{Biostrings::DNAStringSet} class containing the reference sequence, a path to a fasta file containing one sequence, or a NCBI GenBank accession number.
#' @param output Path to the output folder
#' @param run_name Character. Run name to be assigned to output files. 
#' @param trim_args Named list. Arguments to be passed to [sangeranalyseR::SangerRead()].
#' @param AlignSeqs_args Named list. Arguments to be passed to [DECIPHER::AlignSeqs()].
#' @param AdjustAlignment_args Named list. Arguments to be passed to [DECIPHER::AdjustAlignment()].
#' @param ConsensusSequence_args Named list. Arguments to be passed to [DECIPHER::ConsensusSequence()].
#' @param browse Logical. Whether to open browser showing the alignments. Default to \code{FALSE}
#' @param no_file Logical. Whether to write assembled contigs into a fasta file. Default to \code{TRUE}
#' 
#' @return Assembled contigs in DNAStringSet class. 
#' 
#' @export
assemble_map_reference <- function(
    source_folder,
    contig_name_regex,
    primers,
    reference,
    output,
    run_name = NULL,
    trim_args = list(),
    AlignSeqs_args = list(),
    AdjustAlignment_args = list(),
    ConsensusSequence_args = list(),
    output_file = T,
    browse = F
) {
    lifecycle::deprecate_warn(
        when = "0.0.1.9001",
        what = "assemble_map_reference()"
    )
    ab1_paths <- list.files(
        source_folder,
        pattern = "\\.ab1$",
        full.names = TRUE
    )

    contig_map <- data.frame(
        filepath = ab1_paths,
        contig = ab1_paths %>% basename() %>% stringr::str_extract(contig_name_regex)
    ) %>% dplyr::group_by(contig)

    # Format primer infos
    if (stringr::str_detect(primers, "\\.yaml$")) {
        primers <- yaml::read_yaml(primers) %>% dplyr::bind_rows()
    } else if (
        !all(is.data.frame(primers), names(primers) %in% c("name", "direction", "sequence", "spec"))
    ) {
        cli::cli_abort("`primers` must be a yaml containing a list of primers, or a data.frame. Both should contain (yaml: property; data.frame: column) `name`, `direction`, `sequence`, and `spec` values.")
    }

    # Format reference
    if (class(reference) == "character") {
        if (stringr::str_detect(reference, "\\.fasta$")) { # fasta path
            reference <- Biostrings::readDNAStringSet(reference)
            if (length(reference) > 1) {
                cli::cli_abort("Only one reference sequence allowed.")
            }
        } else { # ncbi
            if (length(reference) > 1) {
                cli::cli_abort("Only one accession number allowed.")
            }
            reference <- .DNAbin2DNAStringSet(ape::read.GenBank(reference)) 
        }
    } else if (class(reference) != "DNAStringSet") {
        cli::cli_abort("`reference` must be a Biostrings::DNAStringSet class, a file path to a fasta file, or an NCBI GenBank accession number, not {reference}. {zhutilsr::.say_no(cli::abort)}")
    }

    names(reference) <- "reference"

    contigs <- contig_map %>% 
        dplyr::group_map(
            ~.assemble_map_reference(
                ab1_paths = .x$filepath, 
                primers = primers, 
                reference = reference, 
                browse = browse)
        ) %>% 
        purrr::reduce(c)
    names(contigs) <- as.character(dplyr::group_keys(contig_map)[[1]])

    output_file <- file.path(output, run_name) %>% sprintf("%s.fasta", .)
    zhutilsr::.safe_write(
        contigs, 
        files = file.path(output, run_name) %>% sprintf("%s.fasta", .), 
        overwrite_args = list(overwrite = T), 
        write_func = Biostrings::writeXStringSet
    )
    stop()
    cli::cli_alert_success("Contigs are written at `{output_file}`.")
}


.assemble_map_reference <- function(
    ab1_paths,
    primers,
    reference,
    browse
) {
    primer_sequences <- primers$sequence
    names(primer_sequences) <- primers$name
    reverse_pattern <- primers[primers$direction == "reverse",]$name %>% paste(collapse = "|") %>% sprintf("(%s)", .)
    
    dna_reads <- ab1_paths %>% 
        rlang::set_names(basename(.)) %>% 
        purrr::map(\(file){
            file_basename <- basename(file)

            is_reverse <- grepl(reverse_pattern, file_basename)

            s_read <- sangeranalyseR::SangerRead(
                readFileName         = file,
                readFeature          = "Forward Read",
                TrimmingMethod       = "M2", 
                M2CutoffQualityScore = 30,
                M2SlidingWindowSize  = 10
            )

            # B. Extract raw sequence
            raw_seq <- sangerseqR::primarySeq(sangerseqR::sangerseq(sangerseqR::read.abif(file)))

            # C. Quality crop
            start_pos <- s_read@QualityReport@trimmedStartPos
            end_pos   <- s_read@QualityReport@trimmedFinishPos
            trimmed_seq <- Biostrings::subseq(raw_seq, start = start_pos, end = end_pos)

            matched_primer_name <- primers$name[sapply(primers$name, function(p) grepl(p, file_basename))]

            if (length(matched_primer_name) > 0 && !is.na(matched_primer_name)) {
                target_primer_dna <- Biostrings::DNAString(primer_sequences[matched_primer_name])
                trimmed_seq <- Biostrings::trimLRPatterns(
                    Lpattern = target_primer_dna,
                    subject = trimmed_seq,
                    max.Lmismatch = 2, # change it to dynamically
                    with.Lindels = FALSE
                )
            } else {
                cli::cli_alert_warning("No primer or primer sequence was matched for sequence {basename(file)}, no primer left-over check or trimming was done, there might be primer sequence remaining.")
            }

            # additional 3' trimming for reads covering PCR primers
            primer_spec <- primers[primers$name == matched_primer_name,]$spec
            if (!is.na(primer_spec %>% stringr::str_detect("forward_end|reverse_end"))) {
                target_primer_spec <- gsub("_end", "_start", primer_spec)
                target_primer_dna <- primers[primers$spec == target_primer_spec,]$sequence %>% purrr::discard(is.na)
                trimmed_seq <- Biostrings::trimLRPatterns(
                    Rpattern = target_primer_dna,
                    subject = trimmed_seq,
                    max.Rmismatch = 2,
                    with.Rindels = FALSE
                )
            }

            if (is_reverse) {
                final_seq <- Biostrings::reverseComplement(trimmed_seq)
            } else {
                final_seq <- trimmed_seq
            }

            return(final_seq)
        }) %>% Biostrings::DNAStringSet()

    seq_names <- names(dna_reads)

    combined_seqs <- c(reference, dna_reads)

    get_seq_name <- function(primer_string, all_names) {
        match <- grep(primer_string, all_names, value = TRUE)
        if (length(match) == 0) return(NA)
        return(match[1])
    }

    ordered_reads <- c("reference", sapply(primers$name, get_seq_name, all_names = seq_names) %>% na.omit())
    num_elements <- length(ordered_reads)

    dist_mat <- matrix(0, nrow = num_elements, ncol = num_elements)
    rownames(dist_mat) <- ordered_reads
    colnames(dist_mat) <- ordered_reads

    for (j in 2:num_elements) {
        progressive_distance <- 0.05 * (j - 1)
        dist_mat[j, 1:(j-1)] <- progressive_distance
        dist_mat[1:(j-1), j] <- progressive_distance
    }

    combined_seqs <- combined_seqs[ordered_reads]

    guide_tree <- stats::as.dendrogram(stats::hclust(as.dist(dist_mat), method = "average"))

    aligned_seqs <- DECIPHER::AlignSeqs(
        combined_seqs,
        guideTree    = guide_tree,
        gapOpening   = c(-35, -20),   # Rigid penalties keep the reads intact
        gapExtension = c(-10, -2), # Soft extension allows huge empty spaces before/after tiling reads
        refinements  = 1,
        FUN = function(x, ...) return(x)
    )

    if (browse) aligned_seqs %>% DECIPHER::BrowseSeqs(title = "Map to reference")

    aligned_reads_only <- aligned_seqs[names(aligned_seqs) != "reference"]
 
    aligned_reads_only <- aligned_reads_only %>%
        DECIPHER::AdjustAlignment(
            perfectMatch = 5,
            misMatch     = -1,        # Heavily discourage mismatching close neighbors
            gapLetter    = -1,
            gapOpening   = 0,       # Forbid splintering single bases
            gapExtension = -1       # Encourage sliding bases into the existing main gap block
        )

    if (browse) aligned_reads_only %>% DECIPHER::BrowseSeqs(title = "Assembly after removing reference")

    consensus_contig <- DECIPHER::ConsensusSequence(
        aligned_reads_only,
        threshold      = 0.5,   # Majority rule (>50% agreement among reads present at that position)
        ambiguity      = F,  # Force strict A, T, C, G calls (resolves your remaining ambiguities)
        minInformation = 0.5,
        includeNonLetters = FALSE,
        noConsensusChar = "N"
    )
    consensus_contig <- gsub("-", "", as.character(consensus_contig)) %>% Biostrings::DNAStringSet()

    if (browse) DECIPHER::BrowseSeqs(consensus_contig)

    return(consensus_contig)
}
