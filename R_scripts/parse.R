library(reshape2)
library(splitstackshape)
library(data.table)

file = fread("train_2013.csv")

#split all the columns that need splitting
colsToSplit = colnames(file)[2:19]
split = cSplit(file,splitCols=colsToSplit,sep=" ",direction="long", fixed=FALSE, makeEqual = FALSE)

#make a data table
dt = data.table(split)
setkey(dt,Id)
# find everytime new radar set starts, using time inversion or radar distance change
# as indicator of radar changes
dt[,TimeToEndInversion:=c(1,(sign(diff(TimeToEnd))+1)/2),by=Id]
dt[,NewDistanceToRadar:=c(1,abs(sign(diff(DistanceToRadar)))),by=Id]
dt[,NewRadarIndicator:=TimeToEndInversion | NewDistanceToRadar]

# Now just cummulative sum of previous rows in group to incrementally number the radars
dt[,RadarSeries := cumsum(NewRadarIndicator),by=Id]