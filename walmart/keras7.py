# -*- coding: utf-8 -*-
"""
Created on Sun Dec 27 17:17:10 2015

@author: tscharf
"""

'''Train a LSTM on toy data.

GPU command:
    THEANO_FLAGS=mode=FAST_RUN,device=gpu,floatX=float32 python imdb_lstm.py
'''


import numpy as np
np.random.seed(1337)  # for reproducibility

from keras.preprocessing import sequence
from keras.utils import np_utils
from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation, Merge
from keras.layers.embeddings import Embedding
from keras.layers.recurrent import LSTM
from sklearn.cross_validation import train_test_split
from matplotlib import pyplot as plt
from keras import callbacks
from keras.optimizers import SGD, RMSprop


class plotTest(callbacks.Callback):
    def on_epoch_end(self, epoch, logs={}):
        p = model.predict([X_test_f,X_test])
        plt.scatter(p,test_len, color  = ['r' if i==0 else 'b' for i in y_test ], s= 10)
        plt.axvline(x=0.5)
        plt.xlim([0,1])
        plt.show()
        
# %%
max_features = 10000

pos_center = 50
neg_center = 60
scale = 4

length = np.concatenate((np.random.normal(loc = pos_center,scale = scale, size = max_features//2)\
     ,np.random.normal(loc = neg_center,scale = scale, size = max_features//2)))

var = np.concatenate((np.random.normal(loc = pos_center,scale = scale, size = max_features//2)\
     ,np.random.normal(loc = neg_center,scale = scale, size = max_features//2)))

X = [np.random.uniform(-i,i,size = int(i) ) for i in length]
y = np.repeat((0,1),repeats = (max_features/2,max_features/2))


spread = .05

X_fixed = np.array([np.concatenate((np.random.uniform(0,1-spread, size = max_features//2),\
                   np.random.uniform(spread,1, size = max_features//2))) for i in range(8)]).T

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=40)
X_train_f, X_test_f = train_test_split(X_fixed, test_size=0.2, random_state=40)


test_len =np.array([sum(i!=0) for i in X_test]).flatten()
test_var = np.array([np.var(i) for i in X_test]).flatten()


maxlen = 100  # cut texts after this number of words (among top max_features most common words)
hidden_dim = 64


# %%                                                      


print("Pad sequences (samples x time)")
X_train = np.expand_dims(sequence.pad_sequences(X_train,dtype = 'float32',maxlen = maxlen),axis =2)
X_test = np.expand_dims(sequence.pad_sequences(X_test,dtype = 'float32',maxlen = maxlen),axis =2)


# %%
# fixed data

model_f = Sequential()
model_f.add(Dense(hidden_dim, input_dim=X_train_f.shape[1], init='uniform'))
model_f.add(Activation('tanh'))
model_f.add(Dropout(0.20))

model_f.add(Dense(hidden_dim, init='uniform'))
model_f.add(Activation('tanh'))
model_f.add(Dropout(0.20))

# %%


# sequential data

model_s = Sequential()
model_s.add(LSTM(hidden_dim, return_sequences=False, input_shape = (maxlen,1))) 
model_f.add(Activation('tanh'))
model_s.add(Dropout(0.20))

#model.add(LSTM(hidden_dim, return_sequences=False))
#model.add(Dropout(0.3))



# %%

model = Sequential()
model.add(Merge([model_f,model_s],mode ='concat' ))
model.add(Dense(1, activation = 'sigmoid'))

sgd = SGD(lr=0.1, decay=1e-6, momentum=0.7, nesterov=True)
rms = RMSprop(lr=0.0025, rho=0.9, epsilon=1e-06)
# try using different optimizers and different optimizer configs
model.compile(loss='binary_crossentropy',
              optimizer=rms, class_mode='binary')
# %%
print("Train...")

plots= plotTest()

H = model.fit([X_train_f,X_train], y_train, 
          batch_size=512, 
          shuffle = True,
          verbose   =   1,
          nb_epoch=50,
          show_accuracy=True,
          validation_data = ([X_test_f,X_test],y_test ),
          callbacks = [plots])

# %%
score, acc = model.evaluate([X_test_f,X_test], y_test,
                            batch_size=batch_size,
                            show_accuracy=True)
print('Test score:', score)
print('Test accuracy:', acc)