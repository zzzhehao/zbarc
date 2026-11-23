#' Internal check for packages required by Quarto report templates
#'
#' @param extra_pkgs Optional character vector of additional package names to check.
#' @return Invisibly returns `TRUE` if all required packages are installed; otherwise
#'   stops with an informative message listing missing packages.
#' @noRd
.check_template_dependencies <- function(extra_pkgs = character()) {
  required_pkgs <- unique(c(
    "jsonlite",
    "tidyverse",
    "reactable",
    "htmltools",
    "ape",
    "rcartocolor",
    "rlang",
    "quarto",
    as.character(extra_pkgs)
  ))
  required_pkgs <- required_pkgs[!is.na(required_pkgs) & nzchar(required_pkgs)]

  missing_pkgs <- required_pkgs[
    !vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)
  ]

  if (length(missing_pkgs) > 0) {
    stop(
      sprintf(
        "Missing required package(s) for report template generation: %s.\nPlease install them with: install.packages(c(%s))",
        paste(missing_pkgs, collapse = ", "),
        paste(sprintf('"%s"', missing_pkgs), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

#' Generate an Interactive HTML Report Using Quarto
#'
#' @param input Character vector. Path(s) to input file(s) passed to the Quarto template's
#'   `input` parameter.
#' @param output_file Character. Path where the final HTML report should be saved.
#' @param report_type Character. Type of report to render: `"ncbi"` (`ncbi_blast_report.qmd`),
#'   `"bold"` (`bold_barcodeid_report.qmd`), or `"distance"` (`genetic_distance_report.qmd`).
#' @param description Character. Title or run description passed to the Quarto template.
#'   Defaults to `as.character(Sys.Date())` when omitted.
#' @param standalone Logical. If `TRUE` (default), embeds external resources into a
#'   self-contained HTML file for easy sharing. Set to `FALSE` for faster local
#'   rendering with external supporting files placed alongside `output_file`.
#'
#' @return Invisibly returns the normalized path to the generated HTML file.
#' @family report
#' @export
render_report <- function(
    input, 
    output_file,
    report_type = c("ncbi", "bold", "distance"),
    description,
    standalone = TRUE
) {
    if (!is.logical(standalone) || length(standalone) != 1L || is.na(standalone)) {
        stop("`standalone` must be TRUE or FALSE.", call. = FALSE)
    }
    .check_template_dependencies()
    report_type <- match.arg(report_type)
    input_abs <- normalizePath(input, mustWork = TRUE)

    if (report_type == "ncbi") {
        template_file <- "ncbi_blast_report.qmd"
        output_ext <- "html"
    } else if (report_type == "bold") {
        template_file <- "bold_barcodeid_report.qmd"
        output_ext <- "html"
    } else if (report_type == "distance") {
        template_file <- "genetic_distance_report.qmd"
        output_ext <- "html"
        .validate_aligned_distance_inputs <- function(fasta_paths) {
            for (f in fasta_paths) {
                dna <- tryCatch(
                ape::read.dna(f, format = "fasta"),
                error = function(e) {
                    stop(
                    sprintf("Failed to read FASTA file '%s' for distance report: %s", f, conditionMessage(e)),
                    call. = FALSE
                    )
                }
                )

                if (is.list(dna)) {
                seq_lens <- lengths(dna)
                if (length(unique(seq_lens)) > 1L) {
                    stop(
                    sprintf(
                        "Distance report requires an aligned FASTA with equal sequence lengths, but '%s' has unequal sequence lengths (%s). Please provide an aligned FASTA file.",
                        basename(f),
                        paste(unique(seq_lens), collapse = ", ")
                    ),
                    call. = FALSE
                    )
                }
                }
            }
            invisible(TRUE)
        }
        .validate_aligned_distance_inputs(input_abs)
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
    template_path <- system.file("template", template_file, package = "zbarc")
    
    if (template_path == "") {
        stop(sprintf("Template %s not found. Check if the package is installed correctly.", template_file))
    }

    
    # 3. Create a clean temporary directory for rendering
    temp_dir <- tempfile(pattern = "report_quarto_")
    dir.create(temp_dir)
    on.exit(unlink(temp_dir, recursive = TRUE)) # Clean up when function exits
    
    # Copy template to the temporary directory
    # Copy template and all partials/includes to the temporary directory
    template_dir <- system.file("template", package = "zbarc")
    file.copy(
        list.files(template_dir, full.names = TRUE),
        temp_dir,
        overwrite = TRUE,
        recursive = TRUE
    )

    temp_qmd <- file.path(temp_dir, "report.qmd")
    file.copy(template_path, temp_qmd, overwrite = TRUE)
    
    # 4. Render the document using Quarto, passing the variables to 'params'
    message(sprintf("Rendering %s report. This may take a moment...", report_type))
    quarto::quarto_render(
        input = temp_qmd,
        output_format = "html",
        metadata = list("embed-resources" = standalone),
        execute_params = list(
            input = input_abs,
            description = description
        ),
        quiet = F
    )
    
    # 5. Move the rendered HTML to the user's requested output path
    rendered_html <- file.path(temp_dir, "report.html")

    if (!standalone) {
        rendered_stem <- tools::file_path_sans_ext(basename(rendered_html))
        rendered_files_dir <- file.path(temp_dir, paste0(rendered_stem, "_files"))
        if (dir.exists(rendered_files_dir)) {
            out_dir <- dirname(output_file)
            if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
            out_stem <- tools::file_path_sans_ext(basename(output_file))
            
            target_files_dir <- file.path(out_dir, paste0(out_stem, "_files"))
            unlink(target_files_dir, recursive = TRUE)
            file.copy(rendered_files_dir, out_dir, recursive = TRUE)
            copied_sub <- file.path(out_dir, paste0(rendered_stem, "_files"))

            if (!identical(copied_sub, target_files_dir) && dir.exists(copied_sub)) {
                file.rename(copied_sub, target_files_dir)
            }
        }
    }
    
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
#' @param metadata Optional `data.frame` containing sequence/specimen metadata. Column types
#'   control sorting and filtering in the **Overview & Metadata** tab:
#'   \itemize{
#'     \item **Numeric (`numeric`, `integer`):** Treated as continuous variables with numeric
#'       sorting and range filtering (e.g., `10 - 25`, `>= 15`, `<= 50`).
#'     \item **Factor (`factor`):** Treated as discrete categorical variables with **exact-match**
#'       filtering, supporting multiple selections via dropdown or comma-separated values
#'       (e.g., `Site I, Site VII`). Any discrete variable must be passed as a `factor` (or
#'       `character` if substring matching is desired). A warning is issued if a factor level
#'       or value contains `,`.
#'     \item **Character (`character`):** Treated as pure character strings using standard
#'       substring/text matching.
#'   }
#'   Default is `NULL`.
#' @param key_col Unquoted column name in `metadata` matching sequence names. Default is `NULL`.
#' @param aligned Logical. If `FALSE`, aligns `fasta` via [mafft()] before rendering. Default is `TRUE`.
#' @param output_file Character. Path where the final HTML report should be saved.
#' @param description Character. Title or description of the run. Default is `as.character(Sys.Date())`.
#' @param mafft_args Character vector or `NULL`. Additional arguments passed to [mafft()] when
#'   `aligned = FALSE`. Default is `NULL`.
#' @param extra_reports Optional S7 object or list of objects created by
#'   [extra_report_spec()] to add extra report tabsets and overview columns.
#'   Default is `NULL`.
#' @param standalone Logical. If `TRUE` (default), embeds external resources into a
#'   self-contained HTML file for easy sharing. Set to `FALSE` for faster local
#'   rendering with external supporting files placed alongside `output_file`.
#' 
#' @return Invisibly returns the normalized path to the generated HTML file.
#' @family report
#' @export
render_report_barcode <- function(
    bold_jsonl = NULL,
    blast_json = NULL,
    fasta = NULL,
    metadata = NULL,
    key_col = NULL,
    aligned = TRUE,
    output_file,
    description = as.character(Sys.Date()),
    mafft_args = NULL,
    extra_reports = NULL,
    standalone = TRUE
) {
    if (!is.logical(standalone) || length(standalone) != 1L || is.na(standalone)) {
        stop("`standalone` must be TRUE or FALSE.", call. = FALSE)
    }

    has_bold <- !is.null(bold_jsonl) && length(bold_jsonl) > 0L && any(nzchar(bold_jsonl))
    has_blast <- !is.null(blast_json) && length(blast_json) > 0L && any(nzchar(blast_json))
    has_fasta <- !is.null(fasta) && length(fasta) > 0L && any(nzchar(fasta))

    if (!has_bold && !has_blast && !has_fasta) {
        stop(
            "At least one report input (`bold_jsonl`, `blast_json`, or `fasta`) must be provided. Metadata alone is not sufficient to generate a combined report.",
            call. = FALSE
        )
    }

    # 1. Align FASTA if provided and required
    if (has_fasta && !aligned) {
        if (Sys.which("mafft") == "") {
            stop("MAFFT is not installed or not in PATH. Please install it from https://mafft.cbrc.jp/alignment/software/", call. = FALSE)
        }

        message("Aligning sequence with MAFFT...")
        aligned_fasta <- tempfile(fileext = ".fasta")
        zbarc::mafft(input = fasta, output = aligned_fasta, browse = FALSE, args = mafft_args)
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

        for (col_nm in names(metadata)) {
            if (is.factor(metadata[[col_nm]])) {
                lvls <- unique(c(levels(metadata[[col_nm]]), as.character(metadata[[col_nm]])))
                lvls <- lvls[!is.na(lvls)]
                bad_lvls <- lvls[grepl(",", lvls, fixed = TRUE)]
                if (length(bad_lvls) > 0) {
                    warning(sprintf(
                        "Metadata factor column '%s' contains comma(s) in value(s)/level(s) (%s). Commas are used as multi-value filter delimiters in the Overview table.",
                        col_nm,
                        paste(sprintf("'%s'", unique(bad_lvls)), collapse = ", ")
                    ))
                }
            }
        }

        meta_path <- tempfile(fileext = ".rds")
        saveRDS(metadata, meta_path)
    }

    # 3. Normalize only provided inputs
    bold_abs <- if (has_bold) normalizePath(bold_jsonl, mustWork = TRUE) else character(0)
    blast_abs <- if (has_blast) normalizePath(blast_json, mustWork = TRUE) else character(0)
    fasta_abs <- if (has_fasta) normalizePath(fasta, mustWork = TRUE) else character(0)
    
    temp_dir <- tempfile(pattern = "report_quarto_")
    dir.create(temp_dir)
    on.exit(unlink(temp_dir, recursive = TRUE))
    
    # Copy template and ALL partials to temp directory
    # (Assumes your partials are stored in the 'template' folder)
    file.copy(list.files(system.file("template", package = "zbarc"), full.names = TRUE), temp_dir)

    extra_reports_path <- ""
    if (!is.null(extra_reports)) {
        if (inherits(extra_reports, "barcoding_extra_report")) {
            extra_reports <- list(extra_reports)
        }
        if (!is.list(extra_reports) || !all(vapply(extra_reports, inherits, logical(1), "barcoding_extra_report"))) {
            stop("`extra_reports` must be an object or list created by `extra_report_spec()`.")
        }
        extra_reports_path <- tempfile(fileext = ".rds")
        saveRDS(extra_reports, extra_reports_path)
    }

    template_file <- "barcode_combined_report.qmd"
    template_path <- system.file("template", template_file, package = "zbarc")
    
    if (template_path == "") {
        stop(sprintf("Template %s not found.", template_file))
    }
    
    if (!grepl("\\.html$", output_file, ignore.case = TRUE)) {
        output_file <- paste0(output_file, ".html")
    }

    out_dir <- dirname(output_file)
    if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
    out_stem <- tools::file_path_sans_ext(basename(output_file))

    message("Rendering Combined Barcode Report. This may take a moment...")
    quarto::quarto_render(
        input = file.path(temp_dir, template_file),
        output_format = "html",
        metadata = list(
            format = list(
                html = list("embed-resources" = standalone)
            )
        ),
        execute_params = list(
            bold_input = bold_abs,
            blast_input = blast_abs,
            fasta_input = fasta_abs,
            metadata_path = meta_path,
            key_col = key_col_str,
            description = description,
            extra_reports_path = extra_reports_path
        ),
        quiet = FALSE
    )

    rendered_html <- file.path(temp_dir, "barcode_combined_report.html")

    if (!standalone) {
        rendered_files_dir <- file.path(temp_dir, "barcode_combined_report_files")
        target_files_dir <- file.path(out_dir, paste0(out_stem, "_files"))
        unlink(target_files_dir, recursive = TRUE)
        if (dir.exists(rendered_files_dir)) {
            file.copy(rendered_files_dir, target_files_dir, recursive = TRUE)
        }
    }

    if (file.exists(rendered_html)) {
        file.copy(rendered_html, output_file, overwrite = TRUE)
        message("Success! Report saved to: ", normalizePath(output_file))
    } else {
        stop("Rendering failed. No HTML output was produced.")
    }
    
    invisible(normalizePath(output_file))
}