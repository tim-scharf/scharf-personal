
# Forked from https://www.kaggle.com/forums/t/13122/visualization/68866
# which was written by https://www.kaggle.com/users/8998/piotrek
# 
# Key differences from original:
# - downsampling to 15000 train examples to run quickly on Kaggle Scripts
# - using ggplot2 for plotting

library(ggplot2)
library(data.table)
library(Rtsne)

X <- as.matrix(fread('train.csv')[,2:94,with=F])
Xtest <- as.matrix(fread('test.csv')[,2:94,with=F])

D <- log1p(rbind(X,Xtest))

tsne <- Rtsne(D, check_duplicates = FALSE, pca = T, 
              perplexity=30, theta=0.5, dims=8)

embedding <- as.data.frame(tsne$Y)
embedding$Class <- as.factor(sub("Class_", "", train_sample[,95]))

p <- ggplot(embedding, aes(x=V2, y=V1, color=Class)) +
  geom_point(size=1.5) +
  guides(colour = guide_legend(override.aes = list(size=6))) +
  xlab("") + ylab("") +
  ggtitle("t-SNE 2D Embedding of Products Data") +
  theme_light(base_size=20) +
  theme(strip.background = element_blank(),
        strip.text.x     = element_blank(),
        axis.text.x      = element_blank(),
        axis.text.y      = element_blank(),
        axis.ticks       = element_blank(),
        axis.line        = element_blank(),
        panel.border     = element_blank())

p
idx = which(embedding$Class %in% c(5,6))
idx = 1:num_rows_sample
plot3d(x=embedding$V1[idx],
       y=embedding$V2[idx],
       z=embedding$V3[idx],
       col=as.numeric(embedding$Class[idx]))

ggsave("tsne.png", p, width=8, height=6, units="in")