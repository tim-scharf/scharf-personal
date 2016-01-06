# -*- coding: utf-8 -*-
"""
Created on Sun Jan  3 18:37:41 2016

@author: tscharf
"""

import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
#np.random.seed(1337)  # for reproducibility

from keras.preprocessing import sequence
from keras.utils import np_utils
from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation, Merge
from keras.layers.embeddings import Embedding
from keras.layers.recurrent import LSTM, GRU
from sklearn.cross_validation import train_test_split
from matplotlib import pyplot as plt
from keras import callbacks
from keras.optimizers import SGD, RMSprop, Adagrad, Adadelta, Adam
from keras.preprocessing import sequence
from seya.layers.recurrent import Bidirectional
from keras.regularizers import l2, activity_l2


class benchmark_ratio(callbacks.Callback):
    def on_epoch_end(self, epoch, logs={}):
        print('this is epoch ' + epoch )        
        #self.model = model_fix
        #p = self.model.predict(X_test_fix)
        #loss = np.abs(p).mean()
        #print( loss/zero_benchmark )
        
# %%

train_file = '/Users/tscharf/data/winton/train.csv'
test_file  = '/Users/tscharf/data/winton/test_2.csv'

df = pd.read_csv(train_file)
df.fillna(value = 0, inplace = True)
#%%
#define some columns

fixed_cols =  ['Feature_'+ str(i) for i in np.arange(1,26)]

X_cols_hf = [ 'Ret_'+ str(i) for i in np.arange(2,121)]
X_cols_day= [ 'Ret_MinusTwo', 'Ret_MinusOne']

y_cols_day= [ 'Ret_PlusOne', 'Ret_PlusTwo']
y_cols_hf =  ['Ret_'+ str(i) for i in np.arange(121,181)]

# sequential X in list format
X_seq = [i for i in df[X_cols_day+X_cols_hf].values]
#counts  = df.apply(lambda x: len(x.unique()))
#dummify = counts[counts<15]

X_fix = np.array(df[fixed_cols+X_cols_day])

y = np.array(df[y_cols_day])
 # %%
rs = 102
X_train_fix, X_test_fix, y_train, y_test = train_test_split(X_fix, y, test_size=0.2, random_state=rs)
X_train_seq, X_test_seq = train_test_split(X_seq, test_size=0.2, random_state=rs)


print("Pad sequences (samples x time)") ## no padding in this case
X_train_seq = np.expand_dims(sequence.pad_sequences(X_train_seq,dtype = 'float32'),axis =2)
X_test_seq = np.expand_dims(sequence.pad_sequences(X_test_seq,dtype = 'float32'),axis =2)

zero_benchmark = np.abs(y_test).mean()
# %%
hidden_dim = 128
sgd = SGD(lr=0.1, decay=1e-6, momentum=0.7, nesterov=True)
rms = RMSprop(lr=0.0025, rho=0.9, epsilon=1e-06)

#%%



model_fix = Sequential()

model_fix.add(Dense(hidden_dim,input_dim =X_train_fix.shape[1],activation= 'relu' ))
model_fix.add(Dropout(0.3))
model_fix.add(Dense(2,activation= 'linear'))


# %%

model_fix.compile(loss='mae', optimizer=rms)

# %%

model_fix.fit(X_train_fix,y_train, 
              nb_epoch=40, 
              validation_data= [X_test_fix,y_test],
              verbose = 1,
              batch_size=128,
              callbacks=[benchmark_ratio])

# %%
w = model_fix.get_weights()
z = model_fix.predict(X_test_fix,batch_size=64)

# %%


# sequential data
#lstm = LSTM(output_dim=hidden_dim/2,input_ = 121)
#gru = GRU(output_dim=hidden_dim/2,input_dim=121)  # original examples was 128, we divide by 2 because results will be concatenated
#brnn = Bidirectional(forward=lstm, backward=gru)
# %%
#model_seq = Sequential()
#model_seq.add(brnn)  # try using another Bidirectional RNN inside the Bidirectional RNN. Inception meets callback hell.
#model_seq.add(Dropout(0.5))
#model_seq.add(Dense(2))
#model_seq.add(Activation('linear'))

model_seq = Sequential()
model_seq.add(LSTM(hidden_dim, return_sequences=True, input_shape = (121,1))) 
model_seq.add(Dropout(0.20))
model_seq.add(LSTM(hidden_dim, return_sequences=False))
model_seq.add(Activation('tanh'))
model_seq.add(Dropout(0.2))




# %%

model = Sequential()
model.add(Merge([model_fix,model_seq],mode ='concat' ))
model.add(Dense(2, activation = 'linear'))


# try using different optimizers and different optimizer configs
model.compile(loss='mae',
              optimizer=rms, class_mode='binary')


# %%


H = model.fit([X_train_fixed,X_train_seq], y_train, 
          batch_size=256, 
          shuffle = True,
          verbose   =   1,
          nb_epoch=5,
          show_accuracy = True,
          validation_data = ([X_test_fixed,X_test_seq],y_test ),
          callbacks = [])
          
          


