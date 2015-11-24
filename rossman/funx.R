RMSPE_objective <- function(preds, dtrain) {
  labels <- getinfo(dtrain, "label")
  grad <- ifelse(labels == 0, 0, (preds-labels)/(labels**2))
  hess <- ifelse(labels == 0, 0, 1/(labels**2))
  return(list(grad = grad, hess = hess))
  }

evalerror <- function(preds, dtrain) {
  labels <- getinfo(dtrain, "label")
  idx <- which(labels!=0)
  err <- as.numeric(  sqrt(mean((preds[idx]-labels[idx])/labels[idx])**2))
  return(list(metric = "RMSPE", value = err))
}