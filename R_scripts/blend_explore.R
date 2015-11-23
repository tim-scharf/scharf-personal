load('xgb_models_boost//DATA_0.440506')
blend = DATA$P_valid
blend_idx <- setdiff(1:61878,DATA$idx)

load('xgb_models//DATA_0.452113')
xgb = DATA$P_valid
xgb_idx <- setdiff(1:61878,DATA$idx)

y_idx  <- intersect(xgb_idx,blend_idx) 

X0 <- xgb[xgb_idx %in% y_idx,]
X1 <- blend[blend_idx %in% y_idx,]

y= as.numeric(readRDS('y'))-1

z <- sapply(seq(0,1,length.out = 100),function(a)
  multi_logLoss(( X0*a + X1*(1-a))/2,y[y_idx]))


