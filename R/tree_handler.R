#' Snapshot the MrBayes Result During the Analysis
#' 
#' @description
#' This function allows a visualization of a consensus tree with currently sampled tree without stopping the MrBayes process.
#' 
#' @param assets_date Date of the asset folder where the MrBayes analysis process is located in. This is a project-specific data structure adaptation. It just simplifies the location of the target files. 
#' @param outgroup Sequence labels of the outgroup sequences. It will use automatic gap detection to find the sequences so it allows a certain degree of ambiguity in the name. 
#' @param subfolder Subfolder where the MrBayes process is located under the asset folder of the date. This is a project-specific data structure adaptation. It just simplifies the location of the target files. 
#' @param treeviz logical. Whether to visualize the tree. Default to TRUE.
#' @param xlim.factor Factor to expand the x-axis of the tree. Increase this value if long labels are omitted because they exceed the plotting area.
#' 
#' @return A ggplot of visualized tree if `treeviz` is set to TRUE. A tidytree "treedata" class object if `treeviz` is set to FALSE.
#' @export
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
#' 
#' @param assets_path Path to \code{.con.tre} file or the folder containing the file. If to the folder, there could only be one \code{.con.tre} file in the folder.
#' @return A tidytree treedata object.
#' @export
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

#' Relabel Tree's Tip Labels 
#' 
#' @param tree A tidytree treedata object.
#' @param identifier What identifier stands for. Default to \code{sequence} which means the taxa name of the tree is the sequence name. Set this to \code{organism} when running concatenated analysis, taxa name of the tree is the organism name.
#' @return A relabeled tidytree treedata object.
#' @details
#' Sometimes the bad input mapper could case C++ level crash when bad labeled tree are passed to [ggtree::ggtree] for plotting. In such case, there are probably duplicated labels passed to tree tip label by this function. Check your input mapper for duplicated values, use [dplyr::distinct] to clean up before input.
#' @export
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
#' @param tree A tidytree treedata object.
#' @param outgroup Name of the outgroup that can be used to find all outgroup taxa. The name will be matched against tip label of the tree, and the best matching labels are used as outgroup. This argument will be ignored if `outgroups` is given.
#' @param outgroups A vector of characters that contains all taxa labels of the outgroups.
#' @param match.method If \code{outgroup} is specified, how to find the outgroup taxa. \code{best} try to find all taxa whose name resembles the input, \code{include} find all taxa that includes the input in their name.
#' 
#' @details
#' A proper rerooting is currently only guaranteed for consensus tree produced by MrBayes, due to inconsistent usage of the branch support value across variety of phylogenetic analysis programs. Details see Czech et al. 2017.
#' 
#' @return A rerooted tidytree treedata object.
#' 
#' @references Czech, L., Huerta-Cepas, J. and Stamatakis, A. (2017) “A Critical Review on the Use of Support Values in Tree Viewers and Bioinformatics Toolkits,” Molecular Biology and Evolution, 34(6), pp. 1535–1542. Available at: https://doi.org/10.1093/molbev/msx055.
#' @export
tree_reroot <- function(tree, outgroup, outgroups = NULL, match.method = NULL) {
    # Set node no. as numeric for later reroot operation
    tree@data$node <- as.numeric(tree@data$node)

    if (is.null(outgroups)) {
        if (match.method == "best") {
            outgroups <- zhutilsr::find_best_match(outgroup, tree@phylo$tip.label, silent = T)
            cat("\nOutgroup given as:", outgroup, "\nMatched", outgroups, "\n\n")
        } else if (match.method == "include") {
            outgroups <- tree@phylo$tip.label[stringr::str_detect(tree@phylo$tip.label, outgroup)]
            cat("\nOutgroup given as:", outgroup, "\nMatched", outgroups, "\n\n")
        } else {
            cli::cli_abort("{.var match.methoc} must be either 'best' or 'include', not '{match.method}'")
        }
        
        if (length(outgroups) == 0) {
            cli::cli_abort("Outgroup not found. Given as {outgroup}.")
        } else {
            cli::cli_alert_success("Outgroup given as: {outgroup}, method: {match.method}, matched: \n\n {paste(outgroups, collapse = '\n\n')}\n\n")
        }
    }

    tree.rt <- ape::root(tree, outgroups, resolve.root = T, edgelabel = F)

    tree.rt@phylo$tip.label <- tree@phylo$tip.label # previous ape::root will turn tree.rt tip label into sequencial numbers, but the order doesn't change, therefore simply glueing the original label 
    return(tree.rt)
}

#' Visualize Phylogenetic Tree
#' 
#' @param tree A tree for visualization.
#' @param xlim.factor A factor to expand the x axis.
#' @param linesize Thickness of the tree lines. Default to \code{NULL}, which is set automatically by the function.
#' 
#' @return A ggtree object.
#' @export
tree_visualize <- function(
    tree, 
    xlim.factor = 1.5, 
    align = F, 
    taxa.font.size = 3.5, 
    node.font.size = 3.5,
    format.taxa = T,
    linesize = NULL,
    ggtree_args = NULL
) {
    # tree manipulation
    tree.sc <- treeio::rescale_tree(tree, "length_mean")
    xmax <- max(tree.sc@phylo$edge.length)
    
    if (format.taxa){
        # tiplabel.split <- tree.sc@phylo$tip.label %>% 
        #     gsub(" ", "_", .) %>% 
        #     gsub("\\.", "", .) %>% 
        #     gsub("_sp_", "_sp._", .) %>% 
        #     gsub("_cf_", "_cf._", .) %>% 
        #     stringr::str_split("_")

        # italic.idx <- purrr::map(tiplabel.split, \(label.parts){
        #     idx <- purrr::map_vec(label.parts, \(x){
        #         stringr::str_detect(x, "\\bcf\\b|\\bsp\\b|[0-9]|Haploniscidae")
        #     }) %>% which() %>% min()-1
        #     if (idx > 2) {idx <- 2}
        #     return(idx)
        # })

        # tree.sc@phylo$tip.label <- purrr::map2(tiplabel.split, italic.idx, \(label.parts, idx){
        #     if (idx > 0) {
        #         paste(
        #             paste(label.parts[1:idx], collapse = " ") %>% paste0("italic('", ., "')"),
        #             paste(label.parts[-c(1:idx)], collapse = " ") %>% paste0("'", ., "'"),
        #             sep = "~"
        #         )
        #     } else {
        #         paste(
        #             paste(label.parts, collapse = " ") %>% paste0("'", ., "'"),
        #             sep = "~"
        #         )
        #     }
        # })

        tree.sc@phylo$tip.label <- zhutilsr::format_organism_name(tree.sc@phylo$tip.label, "italic('", "')", T) %>% gsub(" ", "~", .)
    }

    tree.ls <- list(tree = tree.sc, xmax = xmax) 
    if (is.null(ggtree_args)) {
        ggtree_args <- list(layout="rectangular")
    } 

    treargs <- list(
        tr = tree.ls[["tree"]],
        size = linesize
    ) %>% 
        c(., ggtree_args) %>% 
        purrr::compact()

    gtre <- do.call(ggtree::ggtree, treargs)

    tree.viz <- gtre +
        ggtree::geom_tiplab(
            nudge_x = 0.003, 
            align = align,
            parse = format.taxa,
            size = taxa.font.size) + 
        ggtree::geom_nodelab(
            ggplot2::aes(label = round(as.numeric(prob), 2)), 
            nudge_x = -0.008,
            nudge_y = 0.4, 
            hjust = 1, 
            size = node.font.size) +
        ggtree::geom_rootedge(rootedge = 0.02) +
        ggtree::xlim(c(0, tree.ls[["xmax"]]*xlim.factor)) +
        ggplot2::scale_y_continuous(expand = c(0.1, 0)) +
        ggtree::geom_treescale(x = 0, y = -1)
    return(tree.viz)
}