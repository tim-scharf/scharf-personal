# -*- coding: utf-8 -*-
"""
Created on Sun Jan  3 18:37:41 2016

@author: tscharf
"""



import numpy as np
import pandas as pd
#np.random.seed(1337)  # for reproducibility

from keras.preprocessing import sequence
from keras.utils import np_utils
from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation, Merge
from keras.layers.embeddings import Embedding
from keras.layers.recurrent import LSTM
from sklearn.cross_validation import train_test_split
from matplotlib import pyplot as plt
from keras import callbacks
from keras.optimizers import SGD, RMSprop, Adagrad, Adadelta, Adam

# %%


train_file = '/Users/tscharf/data/winton/train.csv'

test_file  = '/Users/tscharf/data/winton/test_2.csv'

df = pd.read_csv(train_file)
hf_cols =  ['Ret_'+ str(i) for i in np.arange(2,181)]

counts  = df.apply(lambda x: len(x.unique()))
dummify = counts[counts<15]

