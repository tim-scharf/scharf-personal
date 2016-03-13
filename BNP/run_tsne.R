setwd('~/repos/scharf-personal/BNP/')
M <- readRDS('data_objects/MTSNE.rds')
source('tnse_loop.R')
tnse_loop(M=M,model_dir = 'tsne_loop/')
