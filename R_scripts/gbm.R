setwd('~/NER/')
source('funcx.R')
require('gbm')
require(Metrics)
require(abind)

X <- buildData()

Xtrain <- X[X$subject%in%train_subs,]
cols =names(Xtrain)[!names(Xtrain)%in%c('subject','FB')] ############remove subject FB

##############################################################3
hypers = expand.grid(list(depth = 1:5, leaf = 4^(2:5)))
hypers

for( h in nrow(hypers)){
  
max_trees=4000
eta=.005
minleaf = 500
depth= 2
bag = .5
##################### tree params

gbm_list <- foreach(i = 1:8)%dopar%
{ 
  #train model out of of fold
  subs = train_subs[c(i,i+8)]
  train_idx = !Xtrain$subject%in%subs
  
  gbm1 = gbm.fit(x= Xtrain[train_idx,cols,with=F],
                 y=y[train_idx],

        distribution = "bernoulli",
        n.trees = max_trees,
        interaction.depth = depth,
        n.minobsinnode = minleaf,
        shrinkage = eta,
        bag.fraction = bag,
        verbose = F)
gbm1
}



M_gbm <- foreach(i = 1:8)%dopar%
{ 
   
  subs = train_subs[c(i,i+8)]
  train_idx = !Xtrain$subject%in%subs
  
  Xtrain_train_fold = Xtrain[train_idx,cols,with=F]
  y_train_fold  = y[train_idx]
  
  Xtrain_test_fold = Xtrain[!train_idx,cols,with=F]
  y_test_fold   = y[!train_idx]
  
  trees_to_check <- 20
  M = matrix(0,nrow=trees_to_check,ncol=2)
  colnames(M) <- c('test','train')
  
  for(j in 1:trees_to_check)
  { 
    n.trees <- round(max_trees*(j/trees_to_check))
    p_train <- predict(gbm_list[[i]],newdata=Xtrain_train_fold, n.trees = n.trees,type='response')
    p_test <- predict(gbm_list[[i]],newdata=Xtrain_test_fold, n.trees = n.trees,type='response')
    
    M[j,'train']   <- auc(actual=y_train_fold,predicted = p_train)
    M[j,'test']    <- auc(actual= y_test_fold,predicted= p_test)
  }
  M
}






A <- aperm(abind(M_gbm,along=3))
matplot(t(colMeans(A)),type='l',lwd=2)
colMeans(A)







Xtest <- X[subject%in%test_subs,cols,with=F]
p <- predict(gbm_list[[2]],newdata = Xtest,n.trees=1000,type='response')
template = fread('SampleSubmission.csv')
template$Prediction <- p
write.csv(template,file =  'gbm_fold_2',quote=F,row.names=F)


###########################3





