clean <- function(char,na.val= -999){
  char[char=='M'] <- na.val #missing
  char[char=='-'] <- na.val
  char[char=='  T'] <- .01 #trace
  char[is.na(char)] <- na.val #trace
  return(as.numeric(char))}


f_dowle2 = function(DT) {
  for (i in names(DT))
    DT[is.na(get(i)) | !is.finite(get(i)),i:=NA,with=FALSE]
}


f_dowle3 = function(DT) {
  for (i in names(DT))
    DT[is.na(get(i)) | !is.finite(get(i)),i:=-999,with=FALSE]
}