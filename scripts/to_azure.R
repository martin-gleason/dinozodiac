#Load to Azure
library(azuremlsdk)

ws <- load_workspace_from_config()

experiment_name <- "dz_azure"
exp <- experiment(ws, experiment_name)

rnn <- estimator(source_directory = ".",
                 entry_script = "scripts/tidytextmodel.R",
                 compute_target = compute_target)
run <- submit_experiment(exp, rnn)