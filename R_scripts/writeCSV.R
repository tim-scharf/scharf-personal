source('funcx.R')
test_info <- getTestInfo()




yhat2 <- lapply(gbm1, function(x)    predict(x,newdata = X,n.trees=ntrees,type='response'))

P2 <- matrix(unlist(yhat2),ncol=16)

pred <- fread('SampleSubmission.csv')
pred$Prediction <- rowMeans(P)

write.table(pred,file = 'cv_2500trees.csv',row.names=F,quote = F,sep=',')

