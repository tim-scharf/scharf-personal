## make prediction

make_test_pred <- function(model_dir,num_class=3)
  
{
  files  <-  sort(list.files(model_dir,  full.names = T))
  pred_list   <- lapply(  files,  function(x)readRDS(x)$P_test)
  preds <- lapply(pred_list,function(i) matrix(i,ncol=num_class,byrow=T)   )
  pred_sums <- Reduce('+',preds)
  return(pred_sums/length(files))
}
