## make prediction
require(data.table)



response_files = sort(list.files('xgb_models_response/',  full.names = T))
profit_files   = sort(list.files('xgb_models_profit/'  ,  full.names = T))


top_N = length(response_files)  #250

profit   <- lapply(  profit_files[1:top_N],  function(x)readRDS(x)$P_test)
response <- lapply(response_files[1:top_N],  function(x)readRDS(x)$P_test)

y_hat_profit <-   Reduce('+',profit)/length(profit)
y_hat_response <- Reduce('+',response)/length(response)

expected_profit <-  ( y_hat_response * y_hat_profit ) -  30  #### SUBTRACTING 30 !!!!!!!!


file_name = 'submissions/xgb_lev2_top35'
write.table(sub,file = file_name,row.names=F,quote=F,sep=',')


