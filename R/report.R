#' Generate an Interactive HTML Report Using Quarto
#'
#' @param input Character vector. Path(s) to input file(s) passed to the Quarto template's
#'   `input` parameter.
#' @param output_file Character. Path where the final HTML report should be saved.
#' @param report_type Character. Type of report to render: `"ncbi"` (`ncbi_blast_report.qmd`),
#'   `"bold"` (`bold_barcodeid_report.qmd`), or `"distance"` (`genetic_distance_report.qmd`).
#' @param description Character. Title or run description passed to the Quarto template.
#'   Defaults to `as.character(Sys.Date())` when omitted.
#'
#' @return Invisibly returns the normalized path to the generated HTML file.
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

#' Generate a Combined Barcoding HTML Report
#'
#' @param bold_jsonl Character. Path to a BOLD JSONL result file.
#' @param blast_json Character. Path to an NCBI BLAST JSON result file.
#' @param fasta Character. Path to a sequence FASTA file.
#' @param metadata Optional `data.frame` containing sequence/specimen metadata. Default is `NULL`.
#' @param key_col Unquoted column name in `metadata` matching sequence names. Default is `NULL`.
#' @param aligned Logical. If `FALSE`, aligns `fasta` via [mafft()] before rendering. Default is `TRUE`.
#' @param output_file Character. Path where the final HTML report should be saved.
#' @param description Character. Title or description of the run. Default is `as.character(Sys.Date())`.
#' @param mafft_args Character vector or `NULL`. Additional arguments passed to [mafft()] when
#'   `aligned = FALSE`. Default is `NULL`.
#'
#' @return Invisibly returns the normalized path to the generated HTML file.
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