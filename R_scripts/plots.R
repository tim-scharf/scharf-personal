
run_idx <- sample(1:length(pred),4700,replace = T)

z <- pred[run_idx]
yy <- as.numeric(y)[run_idx]

auc(yy,z)
#.960

n = 10000

bag1 <- numeric(length=n)
bag2 <- numeric(length=n)

for(i in 1:n){  
  samp <- sample(1:length(z), .3*length(z))
  
  bag1[i] <- auc(yy[samp],  z[samp])
  bag2[i] <- auc(yy[-samp],  z[-samp])
  
}

plot(bag1,bag2)
sd(bag1)
sd(bag2)