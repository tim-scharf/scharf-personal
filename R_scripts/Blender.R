# Dlender

folder = 'xgb_models_boost/'

files = list.files(folder,full.names = T)[81:101]
source('funx.R')

P = matrix(0, ncol= 9,nrow = 144368)

for(file in files){
  load(file)
  P <- P + DATA$P_test
  
}

P  <-  P/rowSums(P)

sub = as.matrix(fread('sampleSubmission.csv'))
sub[,2:10] <- P
write.table(sub,file ='top_20_blend_rf_knn_svm_glm',
            row.names = F, quote=F,sep=',')

n = length(P)
y = as.numeric(readRDS('y'))-1
k = n - 1
i  = 500

B <- matrix(runif(k*i,0,1),ncol = k)
B <- apply(B,1,sort)
B <- t(diff(rbind(rep(0,i),B,rep(1,k))))

blend <- apply(B,1,function(beta) 
  multi_logLoss(  beta[1]*P[[1]] + beta[2]*P[[2]],y[-idx]) )

require(rgl)
require(scatterplot3d)
plot3d( x = B[,1], y =B[,2], z= blend,
               type='p', rainbow(i)[order(blend)])
  