# featureFunx
require(zoo)
#returns euclidean distance from origin of final point on trip
byAir  <- function(pos){ sqrt(sum(pos[nrow(pos),]^2))}
byLand <-  function(pos){ sum(vel(pos))} 

smooth <- function(pos,span=.05){
  t=1:(dim(pos)[1])
  x = pos[,1]
  y = pos[,2]
  zx <- loess(x~t,span=.05)
  zy <- loess(y~t,span=.05)
  pos_smooth = matrix(c(zx$fitted,zy$fitted),ncol=2)
}

roll_sd <- function(pos){rollapply(diff(vel_raw(pos)),4,sd)}

#### added smoothing
vel <-  function(pos){  
  
  v <- sqrt(rowSums(diff(pos)^2))
  silky_v <- rollmean(v[v<60],4)
  silky_v
}

vel_raw <- function(pos){  
  
  v <- sqrt(rowSums(diff(pos)^2))
  
}



acc <- function(pos){ diff(vel(pos),differences = 1)}
jerk  <- function(pos){diff(vel(pos),differences = 2)}
jounce  <- function(pos){diff(vel(pos),differences = 3)}


pt_per_n <- function(pos,alpha=.2,meters = 10){

  
      
  x_spline <- smooth.spline(pos[,'x'],spar=alpha)
  y_spline <- smooth.spline(pos[,'y'],spar=alpha)
  L  = nrow(pos)*50
  dense_x <- predict(x_spline,seq(0,nrow(pos),length.out= L))$y
  dense_y <- predict(y_spline,seq(0,nrow(pos),length.out= L))$y
  g <- matrix(c(dense_x,dense_y),nrow = L)
  d  <- cumsum(vel_raw(g))
  target = seq(0,round(max(d)+meters,-1),by=meters)
  equi_idx <- unlist(lapply(target,function(x) which.min(abs(x-d))))
  new_pos <- g[equi_idx,]
  new_pos
}

delta_heading  <- function(map){
  map2 <- diff(map)
  heading <- atan2(map2[,2],map2[,1])
  dhead <-  diff(heading)
  dhead[dhead>(pi)] <- dhead[dhead>pi] -  2*pi  #correct discontinuity
  dhead[dhead<(-pi)] <- dhead[dhead<(-pi)]+ 2*pi #correct discontinuity
  dhead
  
}

sign.ts <- function(a)lapply(a,function(x)ts(sign(x)))



    

  