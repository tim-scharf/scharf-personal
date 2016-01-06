excludePatients <- function(DT){
  
  #excluded list
  E0 <- fread('~/data/genentech/test_patients_to_exclude.csv')
  E1 <- fread('~/data/genentech/train_patients_to_exclude.csv')
  E <- rbind(E0,E1)
  
  # remove wrong age patients
  DT <- DT[!patient_id%in%E$V1]
  return(DT)
}

importPatients <- function(){
  
  DT0 <- fread('~/data/genentech/patients_train.csv')
  DT1 <- fread('~/data/genentech/patients_test.csv')
  DT <- rbindlist(list(DT0,DT1),use.names = T,fill=T)
  DT[,patient_gender:=NULL]
  setkey(DT,patient_id)
  
  return(DT)
  
  
}

buildFixed <- function(DT){
  
  # data_columns to one-hot encode
  data_cols <-  c("patient_age_group","patient_state",
                  "ethinicity","household_income", "education_level") 
  
  # one hot integer.. make this numeric in python
  M <- model.matrix(~ . -1,data = DT[,data_cols,with=F])
  train_idx <- DT[,!is.na(is_screener)]
  
  y <- as.numeric(DT[train_idx,is_screener])
  M_train <- M[train_idx,]
  M_test <- M[!train_idx,]
  
  setwd('~/data/genentech/')
  npySave(filename= "M_test_fixed.npy", M_test)
  npySave(filename= "M_train_fixed.npy", M_train)
  npySave(filename = "y.npy",y)
  print('successfully saved..')
  return(0)
}

ym2numeric <- function(year,month)
{  return(year*12+month)            }


