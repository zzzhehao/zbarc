# tree_handler.R

#' Snapshot MrBayes Consensus Tree During an Active Analysis
#' 
#' @description
#' Copies ongoing MrBayes `.p`, `.t`, and NEXUS files into a temporary preview subfolder,
#' strips `mcmc` commands and appends `end;` to tree files so a consensus tree can be
#' generated interactively without interrupting the running MrBayes process.
#' 
#' @param assets_path Character. Path to the directory containing active MrBayes output files.
#' @param outgroup Character. Outgroup taxon label used with automatic gap detection on string
#'   distances to root the preview tree.
#' @param subfolder Character. Subfolder name (currently unused in path construction). Default is `""`.
#' @param treeviz Logical. Whether to root, rescale, and plot the consensus tree with `ggtree`.
#'   If `FALSE`, returns the parsed `treedata` object directly. Default is `TRUE`.
#' @param xlim.factor Numeric. Multiplier applied to `xmax` to expand the x-axis for tip labels.
#'   Default is `1.6`.
#' 
#' @return A `ggplot`/`ggtree` object if `treeviz = TRUE`, or a `tidytree` `treedata` object if `treeviz = FALSE`.
midwayTreeViz <- function(assets_path, outgroup, subfolder = "", treeviz = T, xlim.factor = 1.6) {

    # assets_path <- paste("docs/logs/assets", assets_date, subfolder, sep = "/") %>% gsub("/$", "", .)
    intercept.folder <- paste(assets_path, "preview_tree", sep = "/")
    suppressWarnings({dir.create(intercept.folder)})

    mrbayes.files <- list.files(assets_path, "run[0-9]{1}\\.p$|run[0-9]{1}\\.t$")
    nexus.file <- stringr::str_split(mrbayes.files[[1]], "\\.", simplify = T) %>% as.character() %>% .[stringr::str_detect(., "run[0-9]{1}|\\bp\\b|\\bt\\b", negate = T)] %>% paste(collapse = ".")
    intercept.paths <- paste(intercept.folder, c(mrbayes.files, nexus.file), sep = "/")

    file.copy(paste(assets_path, c(mrbayes.files, nexus.file), sep = "/"), intercept.paths, overwrite = T)

    nexus_nomcmc.file <- intercept.paths[[length(intercept.paths)]]

    # remove mcmc command
    lines <- readLines(nexus_nomcmc.file)
    mcmc_lines <- grep('^mcmc', lines)
    if (length(mcmc_lines) > 0) {
    lines <- lines[-mcmc_lines]
    }
    writeLines(lines, nexus_nomcmc.file)

    # add end statement for tree files
    tree.files <- grep("\\.t$", intercept.paths, value = T)
    purrr::walk(tree.files, \(file) {
        write("end;", file, append = T)
    })

    # Manual consensus tree in MrBayes
    cmd <- paste0("exe ", nexus.file)
    w <- readline(paste("Run command` ", cmd, " `at MrBayes console at", intercept.folder, "\n(Type anything to continue, `n` to abort.)\n >>> "))
    if (w == "n") {stop("Abort.")}


    # Tree Viz
    contree <- list.files(intercept.folder, pattern = "\\.con\\.tre$", full.names = T)
    tree <- treeio::read.mrbayes(contree)
    if (treeviz == F) {return(tree)}
        
    # Set node no. as numeric for later reroot operation
    tree@data$node <- as.numeric(tree@data$node)

    # Find exact name of outgroup (automatic gap detection)
    name.dist <- stringdist::stringdistmatrix(tree@phylo$tip.label, outgroup) %>% as.numeric() 
    name.dist.sorted <- name.dist %>% sort()
    weights <- 1/log(name.dist.sorted[-1]+1) # weight gap significance decreasingly while upper value of the gap increases
    maxGapIndex.sorted <- diff(name.dist.sorted)*weights %>% which.max()
    threshold <- mean(name.dist.sorted[c(maxGapIndex.sorted, maxGapIndex.sorted+1)]) # identify the threshold of the gap
    outgroup.match <- tree@phylo$tip.label[name.dist < threshold]

    cat("\nOutgroup given as:", outgroup, "\nMatched", outgroup.match, "\n\n")
    tree.rt <- ape::root(tree, outgroup.match, resolve.root = T, edgelabel = F)

    tree.rt@phylo$tip.label <- tree@phylo$tip.label

    tree.rt.sc <- treeio::rescale_tree(tree.rt, "length_mean")
    xmax <- max(c(tree.rt.sc@phylo$edge.length, tree@phylo$edge.length))
    tree <- list(tree = tree.rt.sc, xmax = xmax)

    tree.viz <- ggtree::ggtree(tree[["tree"]], layout="rectangular") +
        ggtree::geom_tiplab(
            parse = F,
            nudge_x = 0.003, 
            align = F,
            size = 3.8) + 
        ggtree::geom_nodelab(
            ggplot2::aes(label = round(as.numeric(prob), 2)), 
            nudge_x = -0.01,
            nudge_y = 0.2, 
            hjust = 1, 
            size = 3.5) +
        ggtree::geom_rootedge(rootedge = 0.02) +
        ggtree::xlim(c(0, tree[["xmax"]]*xlim.factor)) +
        ggtree::geom_treescale(x = 0, y = 0)
    return(tree.viz)
}

#' Read MrBayes Output Consensus Tree
#' 
#' @param assets_path Character. Path to a `.con.tre` file or a folder containing a single `.con.tre` file.
#'
#' @return A `tidytree` `treedata` object read via [treeio::read.mrbayes()].
#' @export
#' @family tree
read_contree_mrbayes <- function(assets_path) {
    if (stringr::str_detect(assets_path, "\\.con\\.tre$")) {
        contree <- assets_path
    } else {
        contree <- list.files(assets_path, pattern = "\\.con\\.tre$", full.names = T)
    }
    if (length(contree) > 1) {stop("Multiple `.con.tre` files.")}
    tree <- treeio::read.mrbayes(contree)
    return(tree)
}

#' Relabel Tree Tip Labels Using a Lookup Mapper
#' 
#' @param tree A `tidytree` `treedata` object.
#' @param identifier Character. Mode for matching tip labels: `"sequence"` (default) maps tip
#'   labels directly via `identifier` to `c_organism_label`; `"organism"` matches voucher prefixes
#'   (`^ZHH|^VPS`) via `c_organism_id` to `c_organism_label`.
#' @param mapper A `data.frame` lookup table containing mapping columns (`identifier`,
#'   `c_organism_id`, and `c_organism_label`).
#'
#' @return A `tidytree` `treedata` object with updated `@phylo$tip.label`.
#' @details
#' Duplicate labels in the resulting tip labels can cause C++-level errors when passed to
#' [ggtree::ggtree()]. Deduplicate `mapper` (e.g., with [dplyr::distinct()]) beforehand if needed.
#' @export
#' @family tree
tree_relabel <- function(tree, identifier = "sequence", mapper) {
    if (identifier == "sequence") {
        tip.label.fmt <- tree@phylo$tip.label %>% 
            data.frame(identifier = .)
        tip.label.LUT <- dplyr::left_join(tip.label.fmt, mapper)
        tree@phylo$tip.label <- zhutilsr::map_values(tree@phylo$tip.label, tip.label.LUT, identifier, c_organism_label) # a new function to update values according to a LUT dataframe
    } else if (identifier == "organism") {
        mapper <- mapper %>%
            dplyr::select(-identifier) %>%
            dplyr::distinct()

        # now just need to relabel the voucher to informative labels
        idx <- which(stringr::str_detect(tree@phylo$tip.label, "^ZHH|^VPS"))
        tip.label.fmt <- tree@phylo$tip.label
        tip.label.fmt[idx] <-
            tree@phylo$tip.label[idx] %>% 
            data.frame(identifier = .) %>% 
            zhutilsr::map_values(mapper, c_organism_id, c_organism_label)

        tree@phylo$tip.label <- tip.label.fmt
    }

    return(tree)
}

#' Reroot Consensus Tree Produced by MrBayes
#'  
#' @param tree A `tidytree` `treedata` object.
#' @param outgroup Character. Outgroup query string matched against tip labels when `outgroups` is `NULL`.
#' @param outgroups Character vector or `NULL`. Explicit vector of tip labels defining the outgroup.
#' @param match.method Character or `NULL`. Matching strategy when `outgroups` is `NULL`:
#'   `"best"` uses `zhutilsr::find_best_match()`, while `"include"` matches substrings via regex.
#' 
#' @details
#' Proper rerooting is currently only guaranteed for consensus trees produced by MrBayes due to
#' inconsistent conventions for branch support values across phylogenetic tools (see Czech et al., 2017).
#' 
#' @return A rerooted `tidytree` `treedata` object.
#' 
#' @references Czech, L., Huerta-Cepas, J. and Stamatakis, A. (2017) “A Critical Review on the Use of Support Values in Tree Viewers and Bioinformatics Toolkits,” Molecular Biology and Evolution, 34(6), pp. 1535–1542. Available at: https://doi.org/10.1093/molbev/msx055.
#' @export
#' @family tree
tree_reroot <- function (tree, outgroup, outgroups = NULL, match.method = NULL) 
{
    # 1. Enforce integer type (tidytree expects integer node IDs for mapping)
    if (!is.null(tree@data) && "node" %in% colnames(tree@data)) {
        tree@data$node <- as.integer(tree@data$node)
    }
    
    # 2. Repair irregular edge matrices commonly produced by MrBayes/treeio
    phy <- tree@phylo
    ntip <- ape::Ntip(phy)
    nnode <- ape::Nnode(phy)
    
    # tidytree invalidates trees if max node exceeds ntip+nnode, or root != ntip+1
    if (max(phy$edge) > (ntip + nnode) || min(phy$edge[, 1]) != (ntip + 1)) {
        # Find the true root node
        root_node <- unique(phy$edge[, 1][!phy$edge[, 1] %in% phy$edge[, 2]])
        
        if (length(root_node) == 1) {
            # Remap old internal nodes to a perfectly contiguous sequence starting at Ntip + 1
            old_internal <- unique(c(phy$edge[, 1], phy$edge[phy$edge[, 2] > ntip, 2]))
            old_internal <- c(root_node, setdiff(old_internal, root_node))
            new_internal <- seq(ntip + 1, length.out = length(old_internal))
            
            map <- integer(max(phy$edge, na.rm = TRUE))
            map[1:ntip] <- 1:ntip
            map[old_internal] <- new_internal
            
            # Apply mapping to edge matrix
            phy$edge[, 1] <- map[phy$edge[, 1]]
            phy$edge[, 2] <- map[phy$edge[, 2]]
            tree@phylo <- phy
            
            # Apply mapping to data slot so node stats stay perfectly aligned
            if (!is.null(tree@data) && "node" %in% colnames(tree@data)) {
                tree@data$node <- map[tree@data$node]
            }
        }
    }
    
    # 3. Match outgroups
    if (is.null(outgroups)) {
        if (match.method == "best") {
            outgroups <- zhutilsr::find_best_match(outgroup, tree@phylo$tip.label, silent = TRUE)
            cat("\nOutgroup given as:", outgroup, "\nMatched", outgroups, "\n\n")
        }
        else if (match.method == "include") {
            outgroups <- tree@phylo$tip.label[stringr::str_detect(tree@phylo$tip.label, outgroup)]
            cat("\nOutgroup given as:", outgroup, "\nMatched", outgroups, "\n\n")
        }
        else {
            cli::cli_abort("{.var match.method} must be either 'best' or 'include', not '{match.method}'")
        }
        if (length(outgroups) == 0) {
            cli::cli_abort("Outgroup not found. Given as {outgroup}.")
        }
        else {
            cli::cli_alert_success("Outgroup given as: {outgroup}, method: {match.method}, matched: \n\n {paste(outgroups, collapse = '\n\n')}\n\n")
        }
    }
    
    # 4. Root the tree
    # edgelabel = TRUE bypasses the known ape::root.phylo polytomy bug. 
    # tidytree intercepts this and handles the data mapping automatically.
    tree.rt <- ape::root(tree, outgroups, resolve.root = TRUE, edgelabel = TRUE)
    tree.rt@phylo$tip.label <- tree@phylo$tip.label # previous ape::root will turn tree.rt tip label into sequencial numbers, but the order doesn't change, therefore simply glueing the original label 
    
    return(tree.rt)
}

#' Prepare and Format Tree for Plotting
#'
#' @description 
#' Rescales tree branch lengths to `"length_mean"` and optionally formats tip labels using
#' `zhutilsr::format_organism_name()` with spaces converted to tildes (`~`) for plotmath.
#' 
#' @param tree A `tidytree` `treedata` object.
#' @param format.taxa Logical. Whether to format taxa names for plotmath. Default is `TRUE`.
#'
#' @return A rescaled (and optionally formatted) `treedata` object.
#' @export
#' @family tree
.tree_prep_labels <- function(tree, format.taxa = TRUE) {
    tree.sc <- treeio::rescale_tree(tree, "length_mean")
    if (format.taxa) {
        tree.sc@phylo$tip.label <- zhutilsr::format_organism_name(tree.sc@phylo$tip.label, "plot") %>% 
            gsub(" ", "~", .)
    }
    return(tree.sc)
}

#' Calculate Dynamic Layout Offsets for Tree + Heatmap
#'
#' @description 
#' Computes the maximum tree width and determines the horizontal push (`nudge_x`)
#' needed to place tip labels outside a heatmap layer.
#' 
#' @param tree A `tidytree` `treedata` object.
#' @param offset Numeric. Gap between tree tips and the heatmap. Default is `0.01`.
#' @param width Numeric. Heatmap width as a proportion of `tree_width`. Default is `0.1`.
#' @param label_margin Numeric. Space between the heatmap and tip labels. Default is `0.02`.
#'
#' @return A named list with elements `tree_width` and `label_push`.
#' @export
#' @family tree
.tree_calc_offsets <- function(tree, offset = 0.01, width = 0.1, label_margin = 0.02) {
    tree_width <- max(ggtree::ggtree(tree)$data$x)
    label_push <- offset + (tree_width * width) + label_margin
    return(list(tree_width = tree_width, label_push = label_push))
}

#' Visualize Base Phylogenetic Tree
#'
#' @description 
#' Draws the base phylogenetic tree with customizable tip labels, node support labels,
#' root edge, rotation, and scale bar.
#' 
#' @param tree A prepared `tidytree` `treedata` object.
#' @param nodelab_threshold Numeric or `NULL`. Threshold below or equal to which numeric node
#'   labels are hidden (`NA`). Default is `NULL`.
#' @param tree_angle Numeric or `NULL`. Angle in degrees to rotate the tree. Default is `NULL`.
#' @param ggtree_args Named list. Additional arguments passed to [ggtree::ggtree()]. Default is `list()`.
#' @param tiplab_args Named list. Arguments passed to [ggtree::geom_tiplab()].
#' @param nodelab_args Named list. Arguments passed to [ggtree::geom_nodelab()].
#' @param rootedge Numeric. Length of the root edge. Default is `0.02`.
#' @param y.exp Numeric vector of length 2 passed to `expand` in [ggplot2::scale_y_continuous()].
#'   Default is `c(0.1, 0.1)`.
#' @param x.exp Numeric vector of length 2 or `NULL`. Controls x-axis expansion when non-`NULL`.
#'   Default is `NULL` (uses package default behavior).
#' @param treescale_pos Numeric vector of length 2 giving `c(x, y)` coordinates for the tree scale.
#'   Default is `c(0, -1)`.
#' @param treescale_args Named list. Additional arguments passed to [ggtree::geom_treescale()].
#'   Default is `list()`.
#'
#' @return A `ggtree` plot object.
#' @export
#' @family tree
.tree_visualize_base <- function(
    tree, 
    nodelab_threshold = NULL,
    tree_angle = NULL,
    ggtree_args = list(),
    tiplab_args = list(),
    nodelab_args = list(),
    rootedge = 0.02,
    y.exp = c(0.1, 0.1),
    x.exp = NULL,
    treescale_pos = c(0, -1),
    treescale_args = list()
) {
    default_tiplab <- list(size = 3.5, align = FALSE, parse = TRUE)
    default_nodelab <- list(
        mapping = ggplot2::aes(label = round(as.numeric(prob), 2)), 
        size = 3.5, 
        na.rm = TRUE # Automatically suppresses warnings for hidden NA nodes
    )
    
    tiplab_merged <- utils::modifyList(default_tiplab, tiplab_args)
    nodelab_merged <- utils::modifyList(default_nodelab, nodelab_args)
    
    # Apply intelligent thresholding to the mapping aesthetic
    if (!is.null(nodelab_threshold) && !is.null(nodelab_merged$mapping$label)) {
        old_label <- nodelab_merged$mapping$label
        nodelab_merged$mapping$label <- rlang::quo({
            .val <- suppressWarnings(as.numeric(!!old_label))
            # Hide if numeric and below threshold; keep original otherwise
            ifelse(!is.na(.val) & .val <= !!nodelab_threshold, NA, !!old_label)
        })
    }
    
    treargs <- c(list(tr = tree), ggtree_args)
    gtre <- do.call(ggtree::ggtree, treargs)

    if (!is.null(tree_angle)) {
        # 1. Capture the true mathematical radius BEFORE rotation corrupts it
        true_radius <- max(gtre$data$x, na.rm = TRUE)
        
        # 2. Rotate the tree
        gtre <- ggtree::rotate_tree(gtre, tree_angle)
        
        # 3. Inject an invisible dummy node at the true radius
        # This prevents ggtree's alignment lines and gheatmap from collapsing inward.
        dummy_node <- gtre$data[1, ]
        dummy_node$x <- true_radius
        dummy_node$y <- 0
        dummy_node$isTip <- FALSE
        dummy_node$label <- NA
        gtre$data <- rbind(gtre$data, dummy_node)
    }

    treescaleargs <- list(x = treescale_pos[[1]], y = treescale_pos[[2]]) %>% 
        utils::modifyList(treescale_args)
    
    gtre <- gtre +
        do.call(ggtree::geom_tiplab, tiplab_merged) +
        do.call(ggtree::geom_nodelab, nodelab_merged) +
        ggtree::geom_rootedge(rootedge = rootedge) +
        ggplot2::scale_y_continuous(expand = y.exp) + 
        do.call(ggtree::geom_treescale, treescaleargs)

    if (!is.null(x.exp)) {
        xmax <- max(tree@phylo$edge.length)
        gtre <- gtre + ggtree::xlim(c(-0*x.exp[[1]], xmax*x.exp[[2]]))
    }

    return(gtre)
}

#' Add Heatmap Annotation to a Phylogenetic Tree
#'
#' @param p A `ggtree` plot object.
#' @param hm_data A `data.frame` or tibble containing annotation columns indexed by tip label.
#' @param hm_layout Named list specifying `offset` and `width` passed to [ggtree::gheatmap()].
#'   Default is `list(offset = 0.01, width = 0.1)`.
#' @param hm_args Named list. Additional styling arguments passed to [ggtree::gheatmap()].
#'   Default is `list()`.
#' @param palette Character vector of colors, or a list of character vectors for multiple palettes.
#'   Default is `NULL`.
#' @param palette_mapping Named vector or list mapping column names of `hm_data` to indices or
#'   names in `palette`. Default is `NULL`.
#' @param contrast_factor Numeric. Brightness adjustment factor passed to
#'   `zhutilsr::.adjust_palette_brightness()`. Default is `0`.
#'
#' @return A `ggtree` plot object with the heatmap annotation layer added.
#' @export
#' @family tree
tree_annotate <- function(
    p, 
    hm_data, 
    hm_layout = list(offset = 0.01, width = 0.1), 
    hm_args = list(),
    palette = NULL,
    palette_mapping = NULL,
    contrast_factor = 0
) {
    if (inherits(hm_data, "tbl_df")) hm_data <- as.data.frame(hm_data)
    
    default_hm <- list(colnames_angle = 95, colnames_offset_y = -1.5, colnames_offset_x = -0.002, font.size = 2.5)
    hm_merged <- utils::modifyList(default_hm, hm_args)
    
    # --- Smart Palette Mapping Logic ---
    if (!is.null(palette)) {
        # 1. Extract tree tips strictly ordered by their spatial Y-coordinate
        tip_order <- p$data$label[p$data$isTip][order(p$data$y[p$data$isTip])]
        final_colors <- c()
        
        for (col in colnames(hm_data)) {
            # 2. Prefix values to prevent color scale collisions between different columns
            hm_data[[col]] <- ifelse(is.na(hm_data[[col]]), NA, paste0(col, "___", hm_data[[col]]))
            
            # 3. Extract unique values in the exact order they physically appear on the tree
            ordered_vals <- hm_data[tip_order, col]
            ordered_vals <- ordered_vals[!is.na(ordered_vals)]
            unique_vals <- unique(ordered_vals)
            n_vals <- length(unique_vals)
            
            if (n_vals == 0) next
            
            # 4. Route to the correct palette
            if (is.list(palette)) {
                pal_idx <- if (!is.null(palette_mapping) && col %in% names(palette_mapping)) palette_mapping[[col]] else 1
                pal_to_use <- palette[[pal_idx]]
            } else {
                pal_to_use <- palette
            }
            
            # 5. Interpolate palette to exactly match the number of unique groups in this column
            mapped_cols <- if (n_vals == 1) pal_to_use[1] else grDevices::colorRampPalette(pal_to_use)(n_vals)
            mapped_cols <- zhutilsr::.adjust_palette_brightness(mapped_cols, factor = contrast_factor)


            names(mapped_cols) <- unique_vals
            final_colors <- c(final_colors, mapped_cols)
        }
    }
    
    # Draw Heatmap
    heatmap_call <- c(list(p = p, data = hm_data, offset = hm_layout$offset, width = hm_layout$width), hm_merged)
    p_hm <- do.call(ggtree::gheatmap, heatmap_call)
    
    # Inject the unified, spatial-ordered color scale
    if (!is.null(palette)) {
        p_hm <- p_hm + ggplot2::scale_fill_manual(
            values = final_colors, 
            na.value = "transparent",
            labels = function(x) gsub(".*___", "", x) # Secretly strips the prefix if a legend is ever drawn
        )
    }
    
    return(p_hm)
}

#' Visualize a Phylogenetic Tree with Optional Heatmap Annotation
#'
#' @param tree A `tidytree` `treedata` object.
#' @param hm_data Optional `data.frame` for heatmap annotation. If `NULL`, no heatmap is drawn.
#' @param format.taxa Logical. Whether taxa names should be formatted for plotmath. Default is `FALSE`.
#' @param parse Logical. Whether tip labels should be parsed as plotmath expressions. Default is `FALSE`.
#' @param nodelab_threshold Numeric or `NULL`. Hide numeric node labels less than or equal to this value.
#' @param hm_layout Named list of heatmap layout parameters (`offset`, `width`, `label_margin`).
#' @param hm_args Named list of styling arguments passed to [tree_annotate()].
#' @param base_args Named list of rendering arguments passed to [.tree_visualize_base()].
#' @param palette Character vector or list of color vectors for heatmap annotations. Default is `NULL`.
#' @param palette_mapping Named vector or list mapping annotation columns to palettes. Default is `NULL`.
#' @param contrast_factor Numeric. Brightness adjustment factor passed to [tree_annotate()]. Default is `0`.
#'
#' @return A `ggtree` plot object.
#' @export
#' @family tree
tree_visualize <- function(
    tree,
    hm_data = NULL,
    format.taxa = FALSE,
    parse = FALSE,
    nodelab_threshold = NULL,
    hm_layout = list(offset = 0.01, width = 0.1, label_margin = 0.02),
    hm_args = list(),
    base_args = list(
        tiplab_args = list(size = 3, align = TRUE),
        nodelab_args = list(size = 3, nudge_x = 0.001, nudge_y = 0, hjust = 0),
        ggtree_args = list(size = 0.5),
        y.exp = c(0.01, 0.01)
    ),
    palette = NULL,
    palette_mapping = NULL,
    contrast_factor = 0
) {
    if (parse) { 
        if (format.taxa) cli::cli_alert_warning("`parse = TRUE` presumes taxa names are already formatted for plotmath. Ignoring `format.taxa = TRUE`.")
        format.i <- F
        parse.i <- T
    } else {
        parse.i <- format.taxa
        format.i <- format.taxa
    }
    
    clean_tree <- .tree_prep_labels(tree, format.taxa = format.i)
    
    if (!is.null(hm_data)) {
        layout_math <- .tree_calc_offsets(clean_tree, hm_layout$offset, hm_layout$width, hm_layout$label_margin)
        base_args$tiplab_args$nudge_x <- layout_math$label_push
    } 
    
    base_args$tiplab_args$parse <- parse.i
    
    p <- do.call(.tree_visualize_base, c(list(tree = clean_tree, nodelab_threshold = nodelab_threshold), base_args))
    
    if (!is.null(hm_data)) {
        p <- tree_annotate(p, hm_data, hm_layout, hm_args, palette, palette_mapping, contrast_factor)
    }

    return(p)
}