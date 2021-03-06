# How to run PhenoGraph

# Not available in R, so follow steps below instead:

# Requires: Matlab, Statistics Toolbox

# 1. Open "cyt" GUI from Matlab by typing "cyt" in command window.
# 2. Load FCS file by clicking on green "plus" symbol under Gates.
# 3. Select all protein markers under Channels (note: in cyt version 3.0, marker names 
# may show as blank -- in this case, you will need to check the original column names in
# the FCS file, and select markers by counting).
# 4. Right-click and select PhenoGraph.
# 5. Select "Run on individual gates" ("Run on all gates together" may give an error).
# This requires data from all cell populations to be in the same FCS file. If you have
# multiple FCS files, concatenate them together first.
# 6. Set parameters and click "Cluster" to run.
# 7. Save output as a new FCS file by clicking on the save icon under Gates.
