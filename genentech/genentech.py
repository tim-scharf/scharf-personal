# -*- coding: utf-8 -*-
"""
Created on Mon Jan 18 09:55:41 2016

@author: tscharf
"""

import os
import pandas as pd


# %%
data_dir = '/Users/tscharf/data/genentech'
main_dir = '/Users/tscharf/repos/scharf-personal/genentech'

os.chdir(data_dir)
# read in ptient_data
P0 = pd.read_csv('patients_train.csv')
P1 = pd.read_csv('patients_test.csv')

# %%
P = pd.concat([P0,P1])

P.set_index('patient_id', inplace = True, drop = True)
# %%

idx0 = pd.read_csv('train_patients_to_exclude.csv', header = 0 ,names = ['idx'])
idx1 = pd.read_csv('test_patients_to_exclude.csv', header = 0, names = ['idx'])

drop_idx = list(pd.concat((idx0,idx1)).idx.values)



# %%
P.drop(drop_idx,inplace = True)

# %%

A = pd.read_csv('patient_activity_head.csv',nrows = 10000000, verbose = True)
A.set_index('patient_id', inplace = True, drop = True)

