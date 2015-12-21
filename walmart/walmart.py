# -*- coding: utf-8 -*-
"""
Created on Wed Oct 28 09:41:34 2015

@author: tscharf

"""

# repair rec modeling script
import os
import sys

homeDir = os.path.expanduser('~')

path = '{}/'.format(homeDir)

os.chdir(path)

sys.path.append(path)

# %% imports 

from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
from sklearn.grid_search import GridSearchCV
from sklearn.metrics import make_scorer, log_loss, accuracy_score, classification_report
from sklearn.pipeline import Pipeline, FeatureUnion
from sklearn.linear_model import LogisticRegression

import pandas as pd
import numpy as np

# ----------- Uptake Module ---------------
from custom_classes import ItemSelector, Sparsifier, EvalProbs, WriteVal

# %%
# ==============================================================================
#   #### user configs  
#   #### change rawDataFile location to suit your machine 
# ==============================================================================

train_file = '{}/Downloads/train.csv'.format(homeDir)

test_file = '{}/Downloads/test.csv'.format(homeDir)

# %%   
# ==============================================================================
#           LOAD,CLEAN & SPLIT DATA
# ==============================================================================

trainRaw =pd.read_csv(train_file)
testRaw  =pd.read_csv(test_file)
df = pd.concat([trainRaw, testRaw])

df.DepartmentDescription.fillna('DeptNA', inplace =True)
df.FinelineNumber.fillna('FineLineNA', inplace =True)


# %%
# ==================================================================================================
#   set up pipeline --  NOTE: respectable single model can be trained (left in 'decent' hypers as defaults)
# =================================================================================================

# lots to choose from in sklearn
logReg = LogisticRegression(verbose=0, C=6, penalty='l2', tol=.001)

clf = logReg

'''
text of good params from earlier runs - just helps speed through sometimes

searchCV.best_params_
{'union__FAULTS__tfidf_faults__max_features': 1000, 
'union__RXRULES__tfidf_rxRules__norm': 'l2',
 'union__RXRULES__tfidf_rxRules__max_features': 500,
 'union__FAULTS__tfidf_faults__norm': 'l1', 
 'clf__C': 8, 
 'union__FAULTS__tfidf_faults__use_idf': True, 
 'union__RXRULES__tfidf_rxRules__use_idf': True, 
 'union__PMRULES__tfidf_pmRules__use_idf': True, 
 'union__PMRULES__tfidf_pmRules__norm': 'l1', 
 'clf__penalty': 'l2', 
 'union__PMRULES__tfidf_pmRules__max_features': 500}

'''

## fault codes    
sub_pipeline_weekday = Pipeline([('select_Weekday', ItemSelector(key='Weekday')),
                                ('tfidf_faults', TfidfVectorizer(lowercase=False, norm='l1', \
                                                                 use_idf=True, max_features=1250)),
                                ])

## pmRules                     
sub_pipeline_pmRules = Pipeline([('select_pmRules', ItemSelector(key='pmRules')),
                                 ('tfidf_pmRules', TfidfVectorizer(lowercase=False, norm='l1', \
                                                                   use_idf=True, max_features=500)),
                                 ])

##  rxRules                       
sub_pipeline_rxRules = Pipeline([('select_rxRules', ItemSelector(key='rxRules')),
                                 ('tfidf_rxRules', TfidfVectorizer(lowercase=False, norm='l2', \
                                                                   use_idf=True, max_features=500)),
                                 ])

##  isAC  
sub_pipeline_AC = Pipeline([('sparsifier_isAC', Sparsifier(key='isAC'))])

## model 
sub_pipeline_model = Pipeline([('select_model', ItemSelector(key='model')),
                               ('countVect_model', CountVectorizer())])

# bring all our features together    
union = FeatureUnion([('FAULTS', sub_pipeline_faults),
                      ('PMRULES', sub_pipeline_pmRules),
                      ('RXRULES', sub_pipeline_rxRules),
                      ('ISAC', sub_pipeline_AC),
                      ('MODEL', sub_pipeline_model)
                      ])

# -----------   the actual object... nested pipelines   --------------     

pipeline = Pipeline([('union', union), ('clf', clf)])

# %%
# ==============================================================================
#   set up cv structures, further overhead 
# ==============================================================================

## Searchable Params

paramsLogReg = {
    'clf__C': [1, 2, 4, 8, 16, 32, 64],  # regularization greater is less reg.!!
    'clf__penalty': ['l2', 'l1']  # regularization type
}

paramsUnion = {

    'union__FAULTS__tfidf_faults__norm': ['l1', 'l2'],
    'union__PMRULES__tfidf_pmRules__norm': ['l1', 'l2'],
    'union__RXRULES__tfidf_rxRules__norm': ['l2', 'l2'],

    'union__FAULTS__tfidf_faults__use_idf': [True, False],
    'union__PMRULES__tfidf_pmRules__use_idf': [True, False],
    'union__RXRULES__tfidf_rxRules__use_idf': [True, False],

    'union__FAULTS__tfidf_faults__max_features': [1000],
    'union__PMRULES__tfidf_pmRules__max_features': [500],
    'union__RXRULES__tfidf_rxRules__max_features': [500, 100],

}

# ==============================================================================
#  define the  classifier and set searchable params
# ==============================================================================

paramGrid = dict()
paramGrid.update(paramsLogReg)  # add classifier params
paramGrid.update(paramsUnion)  # add feature params

# using logloss as a scorer  in CV gives us our best 'probabilistic' hyper_params
# makes it 'less aggressive' than exact match accuracy search

log_loss_scorer = make_scorer(log_loss,
                              greater_is_better=False,
                              needs_proba=True)

searchCV = GridSearchCV(pipeline,
                        param_grid=paramGrid,
                        verbose=1,  # verbose = 2 more output..
                        cv=4,  # nfolds
                        n_jobs=-2,  # uses all except 1 cores..
                        scoring=log_loss_scorer  # how we choose params
                        )

# ==============================================================================
#  TUNE MODEL 
# ==============================================================================

# LogReg can fit about 20 models per minute +/- using 6 cores
# Expand or contract your search space wtih this is mind
# searchcv does one final fit with best params

# %%
searchCV.fit(trainX, trainY)

pipeline.fit(trainX, trainY)  # just fit what i give it
# %%
# ==============================================================================
#  PREDICT 
# ==============================================================================

predicted = pipeline.predict(testX)
probability = pipeline.predict_proba(testX)

# consolidate Results

print('Exact Match Accuracy: {}'.format(accuracy_score(testY, predicted)))
print('Classification Report:')
print(classification_report(testY, predicted))

if writeResults:
    WriteVal(fname='Nov9_validation.xlsx', model=pipeline, repairCol=repairCol,
                 df=df, predicted=predicted, probability=probability, testY=testY, test_idx=testX.index)
    # WritePickle(fname = 'LEVEL_' + str(repairLevel) + '_FINAL.p', model = pipeline)
    results = [EvalProbs(testY=testY, probability=probability, n=i, pipeline=pipeline) for i in range(1, 15)]
