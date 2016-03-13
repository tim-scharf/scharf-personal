replaceNA <- function(DT,val = -999)
{
  Z <- copy(DT)
for (col in seq_along(Z)) set(Z, i=which(is.na(Z[[col]])), j=col, value=-999)
  return(Z)
  
}