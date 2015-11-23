require(data.table)
source('funx.R')
y =  as.numeric(readRDS('y'))-1

files = list.files('xgb_models_knn_opt/',full.names = T)[1:30]



P <- list()
for(i in 1:length(files)){
  load(files[i])
   P[[i]] <- DATA$P_test

}

X <- Reduce('+',P)/length(P)

X0 <- as.matrix(fread('submissions/BLEND_.4*h20.433_.3*top20blendknn_.3*top60xgb')[,2:10,with=F])
X1 <- as.matrix(fread('submissions/h20_80_.433.csv')[,2:10,with=F])
X2 <- as.matrix(fread('submissions/top_20_blend_rf_knn_svm_glm')[,2:10,with=F])
X3 <- as.matrix(fread('submissions/top60_xgb')[,2:10,with=F])


X4 <- as.matrix(fread('submissions/final_3_equalX_X1_X3')[,2:10,with=F])
X5 <- as.matrix(fread('submissions/blend_submission432_top20_BLEND_sub_matlab_AB_500')[,2:10,with=F])




AP <- abind(P,rev.along = 0)

idx <- combn(1:dim(AP)[3],2)

C <- apply(idx,2,function(i) mean(diag(cor(P[[i[[1]]]], P[[i[[2]]]]) )))


P = (2*X + X1 +X3 + X5)
P = P/rowSums(P)

template = fread('sampleSubmission.csv')
sub <- cbind(template$id, P)
colnames(sub) <- colnames(template)
write.table(sub,'submissions/final_3_2X_X1_X3_X5',sep=',',row.names=F,quote=F)
