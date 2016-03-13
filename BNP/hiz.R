hiz <-function(var,y) { 
  require(ggplot2)
  DT <- data.table(x=var, y = y)
  ggplot(DT, aes(x,fill=factor(y) , colour = factor(y))) + geom_density( alpha = .3 ) 
  
  }