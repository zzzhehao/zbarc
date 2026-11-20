#' Generate an Interactive BLAST Report
#'
#' @param input A character vector of paths to input files.
#' @param output_file The path where the final HTML report should be saved.
#' @param report_type Type of report to render. Currently support \code{ncbi} and \code{bold}. \code{ncbi} takes single-json file from NCBI BLAST result; \code{bold} takes jsonl file from BOLD Barcode ID result. 
#' @param description A string representing the name/title of the run.
#'
#' @return The absolute path to the generated HTML file, invisibly.
#' @export
render_report <- function(
    input, 
    output_file,
    report_type = c("ncbi", "bold", "distance"),
    description
) {
    report_type <- match.arg(report_type)

    if (report_type == "ncbi") {
        template_file <- "ncbi_blast_report.qmd"
        output_ext <- "html"
    } else if (report_type == "bold") {
        template_file <- "bold_barcodeid_report.qmd"
        output_ext <- "html"
    } else if (report_type == "distance") {
        template_file <- "genetic_distance_report.qmd"
        output_ext <- "html"
    }

    if (stringr::str_detect(output_file, sprintf(".%s$", output_ext), T)) {
        output_file <- sprintf("%s.%s", output_file, output_ext)
    }

    if (missing(description)) {description <- as.character(Sys.Date())}

    # Ensure the quarto package is available
    if (!requireNamespace("quarto", quietly = TRUE)) {
        stop("The 'quarto' package is required. Please install it with install.packages('quarto').")
    }

    zhutilsr::dependency_check("quarto", install.packages("quarto"))
    
    # 1. Locate the .qmd template bundled inside your package
    template_path <- system.file("template", template_file, package = "zseq")
    
    if (template_path == "") {
        stop(sprintf("Template %s not found. Check if the package is installed correctly.", template_file))
    }
    
    # 2. Ensure input paths are absolute before moving working directories
    input_abs <- normalizePath(input, mustWork = TRUE)
    
    # 3. Create a clean temporary directory for rendering
    temp_dir <- tempfile(pattern = "report_quarto_")
    dir.create(temp_dir)
    on.exit(unlink(temp_dir, recursive = TRUE)) # Clean up when function exits
    
    # Copy template to the temporary directory
    temp_qmd <- file.path(temp_dir, "report.qmd")
    file.copy(template_path, temp_qmd)
    
    # 4. Render the document using Quarto, passing the variables to 'params'
    message(sprintf("Rendering %s report. This may take a moment...", report_type))
    quarto::quarto_render(
        input = temp_qmd,
        output_format = "html",
        execute_params = list(
            input = input_abs,
            description = description
        ),
        quiet = F
    )
    
    # 5. Move the rendered HTML to the user's requested output path
    rendered_html <- file.path(temp_dir, "report.html")
    
    if (file.exists(rendered_html)) {
        file.copy(rendered_html, output_file, overwrite = TRUE)
        message("Success! Report saved to: ", normalizePath(output_file))
    } else {
        stop("Rendering failed. No HTML output was produced.")
    }
    
    invisible(normalizePath(output_file))
}

#' Generate a Combined Barcoding Report
#'
#' @param bold_jsonl Path to BOLD JSONL file.
#' @param blast_json Path to NCBI BLAST JSON file.
#' @param fasta Path to FASTA file.
#' @param metadata Optional data.frame containing metadata.
#' @param key_col Unquoted column name in `metadata` that matches sequence names.
#' @param aligned Logical. If FALSE, unaligned FASTA will be aligned via MAFFT.
#' @param output_file The path where the final HTML report should be saved.
#' @param description A string representing the name/title of the run.
#' @param mafft_args Additional arguments passed to MAFFT if aligned = FALSE.
#'
#' @export
render_report_barcode <- function(
    bold_jsonl, 
    blast_json, 
    fasta,
    metadata = NULL, 
    key_col = NULL,
    aligned = TRUE, 
    output_file,
    description = as.character(Sys.Date()),
    mafft_args = NULL
) {
  # 1. Align FASTA if required
  if (!aligned) {
    if (Sys.which("mafft") == "") {
      stop("MAFFT is not installed or not in PATH. Please install it from https://mafft.cbrc.jp/alignment/software/")
    }
    
    message("Aligning sequence with MAFFT...")
    aligned_fasta <- tempfile(fileext = ".fasta")
    zseq::mafft(input = fasta, output = aligned_fasta, browse = FALSE, args = mafft_args)
    fasta <- aligned_fasta
  }
  
  # 2. Handle Metadata and Unquoted Key Column
  key_col_quo <- rlang::enquo(key_col)
  key_col_str <- ""
  meta_path <- ""
  
  if (!is.null(metadata)) {
    if (!rlang::quo_is_null(key_col_quo)) {
      key_col_str <- rlang::as_string(rlang::ensym(key_col))
    }
    meta_path <- tempfile(fileext = ".rds")
    saveRDS(metadata, meta_path)
  }
  
  # 3. Quarto Rendering Setup
  zhutilsr::dependency_check("quarto", install.packages("quarto"))
  template_file <- "barcode_combined_report.qmd"
  template_path <- system.file("template", template_file, package = "zseq")
  
  if (template_path == "") {
    stop(sprintf("Template %s not found.", template_file))
  }
  
  # Ensure inputs are absolute
  bold_abs <- normalizePath(bold_jsonl, mustWork = TRUE)
  blast_abs <- normalizePath(blast_json, mustWork = TRUE)
  fasta_abs <- normalizePath(fasta, mustWork = TRUE)
  
  temp_dir <- tempfile(pattern = "report_quarto_")
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE))
  
  # Copy template and ALL partials to temp directory
  # (Assumes your partials are stored in the 'template' folder)
  file.copy(list.files(system.file("template", package = "zseq"), full.names = TRUE), temp_dir)
  
  message("Rendering Combined Barcode Report. This may take a moment...")
  quarto::quarto_render(
    input = file.path(temp_dir, template_file),
    output_format = "html",
    execute_params = list(
      bold_input = bold_abs,
      blast_input = blast_abs,
      fasta_input = fasta_abs,
      metadata_path = meta_path,
      key_col = key_col_str,
      description = description
    ),
    quiet = FALSE
  )
  
  if (!grepl("\\.html$", output_file, ignore.case = TRUE)) output_file <- paste0(output_file, ".html")
  file.copy(file.path(temp_dir, "barcode_combined_report.html"), output_file, overwrite = TRUE)
  message("Success! Report saved to: ", normalizePath(output_file))
  
  invisible(normalizePath(output_file))
}