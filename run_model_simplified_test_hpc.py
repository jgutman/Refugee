from __future__ import division
import sys
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.ensemble import AdaBoostClassifier
from sklearn.cross_validation import train_test_split
from sklearn import linear_model
from sklearn.metrics import roc_auc_score, roc_curve, auc
from sklearn import svm
from sklearn.preprocessing import scale
from StringIO import StringIO
from collections import Counter
from sklearn.metrics import accuracy_score
from inspect import getmembers
from IPython.core.display import Image
from numpy.random import randn
import itertools, operator, sys
from sklearn.linear_model import SGDClassifier
import sklearn.preprocessing

sys.stdout = open("run_model_simplified_test_output.txt", "w")

train_data = pd.read_csv('/scratch/jg3862/train_data_with_time_series_split_by_judge.csv')
test_data = pd.read_csv('/scratch/jg3862/test_data_with_time_series_split_by_judge.csv')

bool_cols = train_data.dtypes[train_data.dtypes == "bool"]
train_data[bool_cols.index] = train_data[bool_cols.index].astype(np.float)
test_data[bool_cols.index] = test_data[bool_cols.index].astype(np.float)

train_data.replace(-1*np.inf, -1000., inplace=True)
test_data.replace(-1*np.inf, -1000., inplace=True)

#Split the 'grantraw' label from train and test records
#collist = [x for x in train_data.columns if x not in ('grantraw')]

X_train = train_data.drop("grantraw", axis=1)
y_train = train_data["grantraw"]

X_test  = test_data.drop("grantraw", axis=1)
y_test  = test_data["grantraw"]

identical = []
for col in X_train.columns:
    if len(X_train[col].unique()) == 1:
        identical = identical + [col]
        
binary = X_train.columns[X_train.max(axis=0) - X_train.min(axis=0) == 1]
nonbinary = [col for col in X_train.columns if col not in (list(binary)+identical)]

#Scale all the values between [0,1]
X_train[nonbinary] = sklearn.preprocessing.normalize(X_train[nonbinary], axis=0) 
X_test[nonbinary] = sklearn.preprocessing.normalize(X_test[nonbinary], axis=0) 

#SIMPLE DECISION TREE MODEL 
clf    = DecisionTreeClassifier()
clf.fit(X_train,y_train)

#Calculate percent Train error
y_tr       = clf.predict(X_train)
train_err  = 100. - (accuracy_score(y_train, y_tr, normalize = True) * 100.)
print " Train error (simple decision tree): ", train_err
        
#Calculate percent Test error
y_te      = clf.predict(X_test)
test_err  = 100. - (accuracy_score(y_test, y_te, normalize = True) * 100.)
print " Test error (simple decision tree): ", test_err

#SIMPLE RANDOM FOREST MODEL 
clf    = RandomForestClassifier()
clf.fit(X_train,y_train)

#Calculate percent Train error
y_tr       = clf.predict(X_train)
train_err  = 100. - (accuracy_score(y_train, y_tr, normalize = True) * 100.)
print " Train error (simple random forest): ", train_err
        
#Calculate percent Test error
y_te      = clf.predict(X_test)
test_err  = 100. - (accuracy_score(y_test, y_te, normalize = True) * 100.)
print " Test error (simple random forest): ", test_err

fig = plt.figure(figsize=(11,4))
plt.plot(np.arange(0, 100, .1),np.arange(0, 100, .1))
fig.savefig("temp.png")
