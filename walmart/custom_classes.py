# -*- coding: utf-8 -*-
"""
Created on Mon Nov  2 10:51:15 2015

@author: tscharf

Module with classes and functions for multi_fault model

"""

# %% Classes for pipline - some necessary overhead 
import numpy as np
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn import preprocessing
import pickle
from  scipy import sparse
import pandas as pd
from sklearn.cross_validation import train_test_split
from sklearn.metrics import roc_auc_score,  accuracy_score, classification_report,  log_loss

# %%

class ItemSelector(BaseEstimator, TransformerMixin):
    '''
    Has both the fit, transform and fit_transform as well => valid pipeline step,
    The BaseEstimator and TransformerMixin allow for grid/random searchable 
    params in pipeline objects
     
    (no searchable parms for this transform)
    '''    
    
    def __init__(self, key):
        self.key = key


    def fit(self, x, y=None):
        return self

    def transform(self, data_dict):
        return data_dict[self.key]    


class Sparsifier(BaseEstimator, TransformerMixin):
    '''
    Has both the fit and transform method => valid pipeline step,
    The BaseEstimator and TransformerMixin allow for grid/random searchable 
    params in pipeline objects 
    (no searchable parms for this transform)
    
    --- THIS CASTS EVERYTHING TO sparse.csr_matrix FLOAT64!!!!! -------- 
    
    
    '''    
    
    def __init__(self, key):
        self.key  = key

    def fit(self, x, y=None):
        return self
                
    def transform(self, data_dict):
        return sparse.csr_matrix( np.array(data_dict[self.key] , dtype = 'float64' )).T   

# %%
# Helper Functions 

def GetValidClasses(repairs, pct = .0025):
    '''    Takes a repairs column from data and a threshold 
    returns a list  [classes] of strings to be used 
    in label creation 
    
    Args:
        repairs: pandas series from data with actual repairs
        pct: float indicating indicating mininum trainable pct 
    
    Returns:
        validClasses: list of unique strings of valid, trainable classes 
       
    '''
    threshold    = pct * len(repairs)
    
    repairCounts = repairs.value_counts()

    valid  =  repairCounts[repairCounts> threshold]
    
    validClasses = list(valid.index)
            
    return validClasses



    
    
def EvalProbs(testY, probability, n, pipeline):
    '''     This evaluates the precision of probabilistic 
    classifier across Arg:n top predictions
    Helper function to evaluate probabilistic output 

    Args:    
        testY:  pandas df 
        probability: numpy array
        n: integer to evaluate precision at
        pipeline: sklearn pipeline object
  
    Returns:
       prec_pct: precsion of pipeline at that level
       
    '''
    
    # maps classes to columns using classes trained on
    lb = preprocessing.LabelBinarizer()
    lb.fit(pipeline.classes_)   
    testYbinary = lb.transform(testY)
    
    # col indices of actual repair
    col_idx = np.argmax(testYbinary, 1) 
    
    ## get the indexes of the top n predictions from probabilities
    top_n_col_idx = np.argpartition(probability, kth = -n, axis = 1)[:,-n:]
    
    # random sanity check
    assert len(col_idx) == len(top_n_col_idx), "something isn't right.."    
    
    ## is the repair column in our top n predictions - boolean 
    prec_bool = [ i in j for i,j in zip( col_idx,top_n_col_idx)]
    
    prec_pct = float(sum(prec_bool)) /  len(prec_bool)
    ## as percentage 
    
    return (prec_pct)


def EvalProbsLoop(testYraw,testX,rez):
    '''     This evaluates the precision of probabilistic 
    classifier across Arg:n top predictions
    Helper function to evaluate probabilistic output 

    Args:    
        testY:  pandas df 
        probability: numpy array
        n: integer to evaluate precision at
        pipeline: sklearn pipeline object
  
    Returns:
       prec_pct: precsion of pipeline at that level
       
    '''
    labels = [i[1]['k'] for i in rez]
    sort_idx = np.argsort(labels)
    p_list = [i[0].predict_proba(testX)[:,1] for i in rez]
    p_array = np.vstack(p_list).T 
    p = p_array[:,sort_idx]
    
    # maps classes to columns using classes trained on
    lb = preprocessing.LabelBinarizer()
    lb.fit(labels)   
    testYbinary = lb.transform(testYraw)
    
    # col indices of actual repair
    col_idx = np.argmax(testYbinary, 1) 

    ## get the indexes of the top n predictions from probabilities
    top_n_col_idx = np.argpartition(p, kth = -n, axis = 1)[:,-n:]
    
    # random sanity check
    assert len(col_idx) == len(top_n_col_idx), "something isn't right.."    
    
    ## is the repair column in our top n predictions - boolean 
    prec_bool = [ i in j for i,j in zip( col_idx,top_n_col_idx)]
    
    prec_pct = float(sum(prec_bool)) /  len(prec_bool)
    ## as percentage 
    
    return (prec_pct)


    
# %%    

def LoadData(rawDataFile, repairLevel):
    '''     This loads in raw data file
   

    Args:    
        rawDataFile: string giving location of file  
        repairLevel: int 1 or 2 telling level we are training
    Returns:
       raw_df: pandas dataframe with data
       repairCol: string identifier of column in raw_df
       
    '''
    # Load data
    raw_df = pd.read_csv(rawDataFile)   

    #extract y colname, handy to have
    repairCol = 'repairCodeLevel{}'.format(repairLevel) # 'repairCodeLevel1' | 'repairCodeLevel2'

    return(raw_df, repairCol)     

# %%
def CleanData(raw_df, repairCol, subset, trimClasses):    
     '''     This cleans up and subsets raw_df
   

     Args:    
        raw_df: pandas df
        repairCol: string of trainable column
        subset: boolean
        trimClasses: boolean
     Returns:
        df: cleaned pandas df
       
     '''    
     
     df = raw_df  
     
     df.pmRules.fillna('' , inplace = True) # pmRules come with NA's
     
     
     #subset only top 28 fault groups   
     if subset:
         df = df[df['containsTopFault'] == 1]
     
     # drop low classes
     if trimClasses:
         validClasses = GetValidClasses(df[repairCol])
         df = df[df[repairCol].isin(validClasses)]
      
     return(df)
     
def SplitData(df, splitType, repairCol, n_time = 124, pct_train = .8):
    '''     This cleans up and subsets raw_df
   

     Args:    
        df: pandas df
        splitType: string 'time' | 'rand'
        repairCol: string
        n_time: int of last examples to hold back
        pct_train: float of random test set to hold back
     Returns:
        (trainX, testX, trainY, testY): pandas df's => YOUR DATA!!
       
    '''        
    df.sort('dateTime',ascending = True, inplace =True) #sort it 
    
    # Split for training and testing
    if splitType == 'time':   
        train_cut = df.shape[0] - n_time
    
        # leave out last n_test for validation
        trainX = df[:train_cut] 
        testX  = df[train_cut:]

        trainY = df[:train_cut][repairCol]
        testY  = df[train_cut:][repairCol]


    if splitType == 'rand':
        trainX, testX, trainY, testY = train_test_split(df, df[repairCol] ,\
        random_state=363, train_size = pct_train)

    
    ## ALWAYS  convert Y to numpy array -- 
    trainY =  np.array(trainY) 
    testY  =  np.array(testY )

    return(trainX, testX, trainY, testY)
     
# %%
     
## TODO : FIX THIS MESS UP ~ fix args
    
def WriteVal( fname, model , repairCol, df, predicted, probability, testY, test_idx, ouput_dir = 'ref/' ):
    ''' writes validation cases testY to Excel Spreadsheet, and
    pickles (compresses) trained model object
    
    Args:
        pickle_name: string filename of output
    
    Return:
        None
    
    V is for (V)alidation! 
    '''
    
    # make a pandas df with asset assetId, timestamp and what was done (Actual)
    V = df.loc[test_idx,['assetId','dateTime', repairCol]]
    
    # layperson friendly column renaming
    V.rename( columns = {repairCol : 'Actual'} ,inplace = True)
    
    # did we predict correctly and associated probability
    V['predicted'] = predicted
    V['score']  =  ['Correct' if i==j else 'Wrong!' for i,j in zip(predicted,testY)] 
    V['probability']  = probability.max(1)
    
    # write excel sheet Reallu useful pandas option
    writer = pd.ExcelWriter( ouput_dir + fname )
    V.to_excel(writer,repairCol)
    writer.save()

    return(V)


def WritePickle(fname , model, output_dir = 'output/master/finalModels/'):
    pickle.dump( model , open(output_dir + fname, 'wb'))
    return      

#%%
def ScoreBinaryModel(testX, testY, searchCV, k):
    '''
    function that evaluates and stores scoring results for single models
    Args:
       TestY : 
       searchCV: python pipeline object
    
    Return:
       Dictionary of key:value pairs of scores
    
    '''
    predicted = searchCV.predict(testX)
    probability = searchCV.predict_proba(testX)
            
    accuracy    = accuracy_score(testY, predicted) 
    logloss     = log_loss(testY, probability[:,1])
    auc         = roc_auc_score(testY, probability[:,1])
    pct         = testY.mean()
    k           = k
    report      = classification_report(testY, predicted)
    
    d = {'acc':accuracy, 'logloss': logloss, 'auc':auc, 'pct': pct,'k':k , 'report':report}
    return(d)
    