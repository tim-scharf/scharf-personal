## make prediction

make_test_pred <- function(model_dir)
  
{
files  <-  sort(list.files(model_dir,  full.names = T))
preds   <- lapply(  files,  function(x)readRDS(x)$P_test)
preds   <- matrix( unlist(preds), ncol = length(preds))

return(rowMeans(preds))
}

