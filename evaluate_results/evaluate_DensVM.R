#########################################################################################
# R script to load and evaluate results for DensVM
#
# Lukas Weber, August 2016
#########################################################################################


library(flowCore)
library(clue)

# helper functions to match clusters and evaluate
source("../helpers/helper_match_evaluate_multiple.R")
source("../helpers/helper_match_evaluate_single.R")
source("../helpers/helper_match_evaluate_FlowCAP.R")
source("../helpers/helper_match_evaluate_FlowCAP_alternate.R")

# which set of results to use: automatic or manual number of clusters (see parameters spreadsheet)
RES_DIR_DENSVM <- "../../results/auto/DensVM"

DATA_DIR <- "../../../benchmark_data_sets"

# which data sets required subsampling for this method (see parameters spreadsheet)
is_subsampled <- c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE)

# alternate FlowCAP results at the end
is_rare    <- c(FALSE, FALSE, FALSE, FALSE, TRUE,  TRUE,  FALSE, FALSE)
is_FlowCAP <- c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  TRUE)
n_FlowCAP <- 2




####################################################
### load truth (manual gating population labels) ###
####################################################

# files with true population labels (subsampled labels if subsampling was required for
# this method; see parameters spreadsheet)

files_truth <- list(
  Levine_32dim = file.path(RES_DIR_DENSVM, "true_labels_DensVM_Levine_32dim.txt"), 
  Levine_13dim = file.path(RES_DIR_DENSVM, "true_labels_DensVM_Levine_13dim.txt"), 
  Samusik_01   = file.path(DATA_DIR, "Samusik/data/Samusik_01.fcs"), 
  Samusik_all  = file.path(RES_DIR_DENSVM, "true_labels_DensVM_Samusik_all.txt"), 
  Nilsson_rare = file.path(DATA_DIR, "Nilsson_rare/data/Nilsson_rare.fcs"), 
  Mosmann_rare = file.path(RES_DIR_DENSVM, "true_labels_DensVM_Mosmann_rare.txt"), 
  FlowCAP_ND   = paste0(RES_DIR_DENSVM, "/true_labels_DensVM_FlowCAP_ND_", 1:30, ".txt"), 
  FlowCAP_WNV  = paste0(RES_DIR_DENSVM, "/true_labels_DensVM_FlowCAP_WNV_", 1:13, ".txt")
)

# extract true population labels

clus_truth <- vector("list", length(files_truth))
names(clus_truth) <- names(files_truth)

for (i in 1:length(clus_truth)) {
  if (!is_subsampled[i]) {
    data_truth_i <- flowCore::exprs(flowCore::read.FCS(files_truth[[i]], transformation = FALSE, truncate_max_range = FALSE))
  } else if (is_subsampled[i] & length(files_truth[[i]]) == 1) {
    data_truth_i <- read.table(files_truth[[i]], header = TRUE, stringsAsFactors = FALSE)
  } else if (is_subsampled[i] & length(files_truth[[i]]) > 1) {
    data_truth_i <- data.frame()
    for (j in 1:length(files_truth[[i]])) {
      data_truth_ij <- read.table(files_truth[[i]][j], header = TRUE, stringsAsFactors = FALSE)
      data_truth_i <- rbind(data_truth_i, data_truth_ij)
    }
  }
  clus_truth[[i]] <- data_truth_i[, "label"]
}

sapply(clus_truth, length)

# cluster sizes and number of clusters
# (for data sets with single rare population: 1 = rare population of interest, 0 = all others)

tbl_truth <- lapply(clus_truth, table)

tbl_truth
sapply(tbl_truth, length)

# store named objects (for other scripts)

files_truth_DensVM <- files_truth
clus_truth_DensVM <- clus_truth




###########################
### load DensVM results ###
###########################

# load cluster labels

files_out <- list(
  Levine_32dim = file.path(RES_DIR_DENSVM, "DensVM_labels_Levine_32dim.txt"), 
  Levine_13dim = file.path(RES_DIR_DENSVM, "DensVM_labels_Levine_13dim.txt"), 
  Samusik_01   = file.path(RES_DIR_DENSVM, "DensVM_labels_Samusik_01.txt"), 
  Samusik_all  = file.path(RES_DIR_DENSVM, "DensVM_labels_Samusik_all.txt"), 
  Nilsson_rare = file.path(RES_DIR_DENSVM, "DensVM_labels_Nilsson_rare.txt"), 
  Mosmann_rare = file.path(RES_DIR_DENSVM, "DensVM_labels_Mosmann_rare.txt"), 
  FlowCAP_ND   = file.path(RES_DIR_DENSVM, "DensVM_labels_FlowCAP_ND.txt"), 
  FlowCAP_WNV  = file.path(RES_DIR_DENSVM, "DensVM_labels_FlowCAP_WNV.txt")
)

clus <- lapply(files_out, function(f) {
  read.table(f, header = TRUE, stringsAsFactors = FALSE)[, "label"]
})

sapply(clus, length)

# cluster sizes and number of clusters
# (for data sets with single rare population: 1 = rare population of interest, 0 = all others)

tbl <- lapply(clus, table)

tbl
sapply(tbl, length)

# contingency tables
# (excluding FlowCAP data sets since population IDs are not consistent across samples)

for (i in 1:length(clus)) {
  if (!is_FlowCAP[i]) {
    print(table(clus[[i]], clus_truth[[i]]))
  }
}

# store named objects (for other scripts)

files_DensVM <- files_out
clus_DensVM <- clus




###################################
### match clusters and evaluate ###
###################################

# see helper function scripts for details on matching strategy and evaluation

res <- vector("list", length(clus) + n_FlowCAP)
names(res)[1:length(clus)] <- names(clus)
names(res)[-(1:length(clus))] <- paste0(names(clus)[is_FlowCAP], "_alternate")

for (i in 1:length(clus)) {
  if (!is_rare[i] & !is_FlowCAP[i]) {
    res[[i]] <- helper_match_evaluate_multiple(clus[[i]], clus_truth[[i]])
    
  } else if (is_rare[i]) {
    res[[i]] <- helper_match_evaluate_single(clus[[i]], clus_truth[[i]])
    
  } else if (is_FlowCAP[i]) {
    res[[i]]             <- helper_match_evaluate_FlowCAP(clus[[i]], clus_truth[[i]])
    res[[i + n_FlowCAP]] <- helper_match_evaluate_FlowCAP_alternate(clus[[i]], clus_truth[[i]])
  }
}

# store named object (for plotting scripts)

res_DensVM <- res



