meta_bag <- function( 
  
  Xtrain,            # This is a matrix, contains train data, data_cols only
  Xtest,             # This is a matrix, contains train data, data_cols only
  y,                 # contains target vars
  model_dir,         # we will make this directory if it doesn't exist
  n_models,          # total model construction
  worker_bee)        # function that saves a DATA structure in model_dir
  
{
  # make directory if it doesn't exist
  ifelse(  !dir.exists(model_dir) , dir.create(model_dir), FALSE)
  
  #Train and test same number of columns
  stopifnot(dim(Xtrain)[2]==dim(Xtest)[2])
  
  
  for(m in 1:n_models){ 
    cat('\n','working on model',m,'\n')
    set.seed(m)
    idx        <- sample(nrow(Xtrain),nrow(Xtrain) , replace = T)    # full bag indexes
    
    worker_bee(
      train = Xtrain,
      test  = Xtest,
      y = y,
      idx = idx,
      model_dir = model_dir,
      m = m)
      
      }
  
}




