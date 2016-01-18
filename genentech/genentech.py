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

# %%

idx_ex_train = pd.read_csv('train_patients_to_exclude.csv')
idx_ex_test = pd.read_csv('test_patients_to_exclude.csv')




