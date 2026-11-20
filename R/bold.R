#' Step 1: Validate Query Triplets
#' @param query A character string (e.g., "tax:Aves;geo:Argentina")
bold_validate_query <- function(query, max_chars = 240) {
  if (nchar(query) <= max_chars) {
    url <- httr::modify_url(
      "https://portal.boldsystems.org/api/query/preprocessor",
      query = list(query = query)
    )
    res <- httr::GET(url)
    httr::stop_for_status(res)
    return(httr::content(res, as = "parsed"))
  }

  # Split long query string into chunks <= max_chars by ";"
  parts <- strsplit(query, ";", fixed = TRUE)[[1]]
  chunks <- character()
  current <- ""

  for (p in parts) {
    if (nchar(p) > max_chars) {
      stop(sprintf("Single query segment exceeds max_chars (%d): %s", max_chars, p), call. = FALSE)
    }
    candidate <- if (nzchar(current)) paste0(current, ";", p) else p
    if (nchar(candidate) <= max_chars) {
      current <- candidate
    } else {
      chunks <- c(chunks, current)
      current <- p
    }
  }
  if (nzchar(current)) chunks <- c(chunks, current)

  all_terms <- purrr::map(chunks, function(q_chunk) {
    url <- httr::modify_url(
      "https://portal.boldsystems.org/api/query/preprocessor",
      query = list(query = q_chunk)
    )
    res <- httr::GET(url)
    httr::stop_for_status(res)
    httr::content(res, as = "parsed")$successful_terms
  }) %>%
    purrr::flatten()

  list(successful_terms = all_terms)
}

#' Step 2: Get Query Token
#' @param validated_query The validated query string from Step 1
#' @param extent Extent of documents (default: "full")
bold_get_token <- function(validated_query, extent = "full") {
  url <- httr::modify_url(
    "https://portal.boldsystems.org/api/query",
    query = list(query = validated_query, extent = extent)
  )
  res <- httr::GET(url)
  if (httr::http_error(res)) {
    err_body <- httr::content(res, as = "text", encoding = "UTF-8")
    stop(sprintf(
      "Query token request failed (HTTP %s, %d chars).\nResponse: %s",
      httr::status_code(res),
      nchar(validated_query),
      err_body
    ), call. = FALSE)
  }

  parsed <- httr::content(res, as = "parsed")
  return(parsed$query_id)
}

#' Step 3: Perform Download
#' @param query_id Token from Step 2
#' @param format Data format ("json", "tsv", or "dwc")
bold_download <- function(query_id, format = "tsv") {
  url <- httr::modify_url(sprintf("https://portal.boldsystems.org/api/documents/%s/download", query_id), 
                          query = list(format = format))
  res <- httr::GET(url)
  httr::stop_for_status(res)
  
  httr::content(res, as = "text", encoding = "UTF-8")
}

#' Read downloaded text directly into R based on format
bold_read_data <- function(raw_text, format) {
  if (format %in% c("tsv", "dwc")) {
    read.delim(text = raw_text, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  } else if (format == "json") {
    # stream_in is strictly required to parse NDJSON (JSON Lines)
    jsonlite::stream_in(textConnection(raw_text), verbose = FALSE)
  } else {
    stop("Unsupported format. Choose 'tsv', 'dwc', or 'json'.")
  }
}

#' Write BOLD data to a desired location utilizing zhutilsr
bold_write_data <- function(obj, dir = NULL, file = NULL, format = "tsv") {
  # Handle when a full path is passed directly to 'file' instead of splitting dir/file
  if (is.null(dir) && !is.null(file)) {
      target_files <- file
      target_file_name <- NULL
  } else if (!is.null(dir) && !is.null(file)) {
      target_files <- NULL
      target_file_name <- file
  } else {
      # Default fallback filename
      file_ext <- ifelse(format == "json", "json", "tsv")
      target_files <- paste0("bold_data_export.", file_ext)
      target_file_name <- NULL
  }
  
  # Ensure file string is safe using your utility (only if it's just a file name)
  if (!is.null(target_file_name)) {
      target_file_name <- zhutilsr::safe_name(target_file_name, replacement = "_", allow = "\\.")
  }

  if (format %in% c("tsv", "dwc")) {
    zhutilsr::safe_write(
        obj, 
        dir = dir, 
        file = target_file_name,
        files = target_files,
        write_func = utils::write.table,
        write_func_args = list(sep = "\t", row.names = FALSE, quote = FALSE)
    )
  } else {
    zhutilsr::safe_write(
        obj, 
        dir = dir, 
        file = target_file_name,
        files = target_files,
        write_func = jsonlite::write_json,
        write_func_args = list(pretty = TRUE)
    )
  }
}

.chunk_query_terms <- function(query_str, max_chars = 240) {
  parts <- unique(strsplit(query_str, ";", fixed = TRUE)[[1]])
  parts <- parts[nzchar(trimws(parts))]

  if (nchar(paste(parts, collapse = ";")) <= max_chars) {
    return(paste(parts, collapse = ";"))
  }

  # Keep non-recordsetcode filters (e.g., tax:, geo:) as shared anchors across chunks
  anchor_parts <- parts[!grepl("^recordsetcode:", parts)]
  var_parts <- parts[grepl("^recordsetcode:", parts)]

  # Fallback if no recordsetcode terms exist
  if (length(var_parts) == 0) {
    chunks <- character()
    cur <- ""
    for (p in parts) {
      if (nchar(p) > max_chars) {
        stop(sprintf("Single query term exceeds max_chars (%d): %s", max_chars, p), call. = FALSE)
      }
      cand <- if (nzchar(cur)) paste0(cur, ";", p) else p
      if (nchar(cand) <= max_chars) {
        cur <- cand
      } else {
        chunks <- c(chunks, cur)
        cur <- p
      }
    }
    if (nzchar(cur)) chunks <- c(chunks, cur)
    return(chunks)
  }

  anchor_str <- paste(anchor_parts, collapse = ";")
  if (nzchar(anchor_str) && nchar(anchor_str) > max_chars) {
    stop(sprintf("Shared query terms exceed max_chars (%d): %s", max_chars, anchor_str), call. = FALSE)
  }

  chunks <- character()
  cur <- anchor_str

  for (vp in var_parts) {
    cand <- if (nzchar(cur)) paste0(cur, ";", vp) else vp
    if (nchar(cand) <= max_chars) {
      cur <- cand
    } else {
      if (!nzchar(cur) || (nzchar(anchor_str) && cur == anchor_str)) {
        stop(sprintf("Query term '%s' cannot fit within max_chars (%d) alongside anchors.", vp, max_chars), call. = FALSE)
      }
      chunks <- c(chunks, cur)
      cur <- if (nzchar(anchor_str)) paste0(anchor_str, ";", vp) else vp
      if (nchar(cur) > max_chars) {
        stop(sprintf("Single chunk exceeds max_chars (%d): %s", max_chars, cur), call. = FALSE)
      }
    }
  }
  if (nzchar(cur)) chunks <- c(chunks, cur)

  unique(chunks)
}


#' Overarching wrapper for BOLD API data retrieval
#' @param query Search terms in scope:term format (e.g. "tax:Aves;geo:Argentina")
#' @param format Desired format ("tsv", "dwc", or "json")
#' @param extent Extent parameter (default "full")
#' @param output_dir Target directory to write files. If NULL, data is only returned to the R environment.
#' @param output_file Target file name. 
#' @export
bold_retrieve <- function(
    query,
    format = "tsv",
    extent = "full",
    output_dir = NULL,
    output_file = NULL,
    max_chars = 240)
{
  query_chunks <- .chunk_query_terms(query, max_chars = max_chars)
  n_chunks <- length(query_chunks)

  dfs <- vector("list", n_chunks)

  for (i in seq_along(query_chunks)) {
    q_chunk <- query_chunks[i]
    prefix <- if (n_chunks > 1) sprintf("[Chunk %d/%d] ", i, n_chunks) else ""

    # 1. Validate
    message(prefix, "1/4: Validating query against BOLD preprocessor...")
    valid_res <- bold_validate_query(q_chunk)
    valid_query <- valid_res$successful_terms %>%
      purrr::map_chr(~ .x$matched) %>%
      unique() %>%
      paste(collapse = ";")

    if (!nzchar(valid_query)) {
      warning(prefix, "No successful terms matched for chunk; skipping.", call. = FALSE)
      next
    }

    # 2. Get Token
    message(prefix, "2/4: Invoking query to get token...")
    token <- bold_get_token(valid_query, extent = extent)

    # 3. Download
    message(prefix, "3/4: Downloading batch records (max 1 million)...")
    raw_text <- bold_download(token, format = format)

    # 4. Read into R
    message(prefix, "4/4: Parsing data into R...")
    dfs[[i]] <- bold_read_data(raw_text, format = format)
  }

  dfs <- purrr::compact(dfs)
  if (length(dfs) == 0) {
    message("No records retrieved across all query chunks.")
    return(NULL)
  }

  # Combine chunks (bind_rows handles slightly differing columns cleanly if dplyr is available)
  bold_df <- if (requireNamespace("dplyr", quietly = TRUE)) {
    dplyr::bind_rows(dfs)
  } else {
    do.call(rbind, dfs)
  }

  # 5. Write to disk if a directory or file is provided
  if (!is.null(output_dir) || !is.null(output_file)) {
    bold_write_data(bold_df, dir = output_dir, file = output_file, format = format)
    message("File saved successfully.")
  }

  return(bold_df)
}
##' Construct and Validate a BOLD API Query
#'
#' @description 
#' Takes vector or list inputs for available BOLD API scopes, formats them, and validates 
#' them against the BOLD API preprocessor to return a formal query string of triplets.
#'
#' @details 
#' The function accepts multiple search criteria to dictate the aggregate data and barcodes returned. 
#' Criteria can be combined to allow for different results:
#' * **Same Scope:** Criteria sharing the same scope combine results into a single result (implicit logical OR).
#' * **Different Scopes:** Criteria of different scopes apply an overlap constraint (implicit logical AND). 
#' 
#' For example, searching for `tax` "Aves" and `geo` "Argentina" returns barcodes that overlap on both the taxonomic and geographic criteria.
#' 
#' For more details, see the BOLD API Documentation: < PASTE_LINK_HERE >
#'
#' @param tax Taxonomic ranks (e.g., kingdom, phylum, class, order, family, subfamily, tribe, genus, species, subspecies). Accepts character vector or list.
#' @param bin Barcode Index Number (BIN) URIs. Accepts character vector or list.
#' @param geo Geopolitical divisions (e.g., country/ocean, province/state, region). Accepts character vector or list.
#' @param inst Institution names or sequence sites. Accepts character vector or list.
#' @param recordsetcode Dataset codes. Accepts character vector or list.
#' @param ids Specimen or sequence IDs (processid, sampleid, insdcacs). Accepts character vector or list.
#'
#' @return A validated query string of formal triplets from the BOLD preprocessor.
#' @export
bold_get_query <- function(
    tax = NULL, 
    bin = NULL, 
    geo = NULL, 
    inst = NULL, 
    recordsetcode = NULL, 
    ids = NULL,
    max_chars = 240) 
{
    format_scope <- function(scope_name, values) {
        if (is.null(values) || length(values) == 0) return(NULL)
        
        val_vec <- unique(as.character(unlist(values)))
        val_vec <- val_vec[!is.na(val_vec) & nzchar(trimws(val_vec))]
        if (length(val_vec) == 0) return(NULL)
        
        paste0(scope_name, ":", val_vec)
    }
    
    phrases <- c(
        format_scope("tax", tax),
        format_scope("bin", bin),
        format_scope("geo", geo),
        format_scope("inst", inst),
        format_scope("recordsetcode", recordsetcode),
        format_scope("ids", ids)
    )
    
    if (length(phrases) == 0) {
        stop("At least one query parameter must be provided.")
    }
    
    # Pack phrases into chunks <= max_chars (accounting for ";" separator)
    chunks <- character()
    current_chunk <- ""
    for (p in phrases) {
        if (nchar(p) > max_chars) {
            stop(sprintf("Single query phrase exceeds max_chars (%d): %s", max_chars, p), call. = FALSE)
        }
        candidate <- if (nzchar(current_chunk)) paste0(current_chunk, ";", p) else p
        if (nchar(candidate) <= max_chars) {
            current_chunk <- candidate
        } else {
            chunks <- c(chunks, current_chunk)
            current_chunk <- p
        }
    }
    if (nzchar(current_chunk)) {
        chunks <- c(chunks, current_chunk)
    }
    
    message(sprintf("Validating query through BOLD preprocessor (%d chunk%s)...",
                    length(chunks), if (length(chunks) == 1) "" else "s"))
    
    matched_terms <- purrr::map(chunks, function(q_chunk) {
        url <- httr::modify_url(
            "https://portal.boldsystems.org/api/query/preprocessor", 
            query = list(query = q_chunk)
        )
        res <- httr::GET(url)
        if (httr::http_error(res)) {
            err_body <- httr::content(res, as = "text", encoding = "UTF-8")
            stop(sprintf(
                "Preprocessor failed (HTTP %s).\nQuery sent (%d chars): %s\nResponse: %s",
                httr::status_code(res),
                nchar(q_chunk),
                q_chunk,
                err_body
            ), call. = FALSE)
        }
        parsed <- httr::content(res, as = "parsed")
        purrr::map_chr(parsed$successful_terms, ~ .x$matched)
    }) %>%
        unlist() %>%
        unique()
    
    if (length(matched_terms) == 0) {
        stop("No successful terms matched by BOLD preprocessor.")
    }
    
    ret <- paste(matched_terms, collapse = ";")
    return(invisible(ret))
}