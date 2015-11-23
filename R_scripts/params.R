n.cores =  detectCores()
driverDir = '~/Downloads/drivers/'
drivers = readRDS('drivers')
nQuants = 10 # our own parameter number of qunatiles to examine
nDrivers = length(drivers) # nDrivers == 2736
nTrips = 200 # fixed for every driver

