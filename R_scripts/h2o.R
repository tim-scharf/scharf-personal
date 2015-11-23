library(h2o)
localH2O <- h2o.init(nthread=8,max_mem_size="8g")

train <- read.csv("train.csv")

test <- read.csv("test.csv")

for(i in 2:94){
  train[,i] <- as.numeric(train[,i])
  train[,i] <- log1p(train[,i])
}


for(i in 2:94){
  test[,i] <- as.numeric(test[,i])
  test[,i] <- log1p(test[,i])
}



train.hex <- as.h2o(localH2O,train)
test.hex <- as.h2o(localH2O,test[,2:94])

predictors <- 2:(ncol(train.hex)-1)
response <- ncol(train.hex)

submission <- read.csv("sampleSubmission.csv")
submission[,2:10] <- 0

for(i in 1:100){
  print(i)
  model <- h2o.deeplearning(x=predictors,
                            y=response,
                            data=train.hex,
                            classification=T,
                            activation="RectifierWithDropout",
                            hidden=c(512,256,128),
                            hidden_dropout_ratio=c(0.25,0.25,0.25),
                            input_dropout_ratio=0.05,
                            epochs=50,
                            l1=1e-5,
                            l2=1e-5,
                            rho=0.99,
                            epsilon=1e-8,
                            train_samples_per_iteration=1000,
                            max_w2=8)
  submission[,2:10] <- submission[,2:10] + as.data.frame(h2o.predict(model,test.hex))[,2:10]
  print(i)
  write.csv(submission,file="submission.csv",row.names=FALSE) 
}      

h2o.shutdown(localH2O)
Y


