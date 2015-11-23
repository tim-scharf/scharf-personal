if(!Sys.info()['user'] %in% c('tim','timscharf'))
{ 
  # install packages in list
  install.packages(packages,dependencies = T)
}
# add them
lapply(packages,library,character.only=T)

