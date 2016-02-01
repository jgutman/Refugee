import sys
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.cross_validation import train_test_split
from sklearn.preprocessing import scale
from __future__ import division
from collections import Counter
from sklearn.metrics import accuracy_score
import os

#Read the refugee data set
data_refugee = pd.read_csv(os.getcwd() + '/asylum_clean_chicago_eoirstrictconsec3_1.csv', low_memory=False)

# Dagsha's method
%%timeit
#Get the last 200 records alone for testing purpose
data = data_refugee.tail(2000).copy()

for i, row in data.iterrows():
    if np.isnan(row['L1grant2']): 
        
        date       = row['comp_date']
        court_code = row['ij_court_code']
        start_time = row['adj_time_start']
                
        idnproc_list = data[(data.comp_date == date) & (data.ij_court_code == court_code) & (data.adj_time_start < start_time)].idnproceeding
        flag = 1
        num_day = 0
        start_time_list = {}
        
        while(flag == 1):            
            if len(idnproc_list) > 0:
                flag = 0
                for idp in idnproc_list:
                    start_time_list[idp] = data[(data.idnproceeding == idp)].adj_time_start.values[0]
                
                prev_proc = max(start_time_list, key=start_time_list.get)
                row['L1grant2'] = data[(data.idnproceeding == prev_proc)].grantraw.values[0]                
            else:
                num_day = num_day + 1
                
                #For test purpose, the number to days to go back is limited to 30 days
                if num_day > 30:
                    flag = 0                                     
                else:                    
                    date       = date - 1                
                    start_time = 2000                
                    idnproc    = data[(data.comp_date == date) & (data.ij_court_code == court_code) 
                    & (data.adj_time_start < start_time)].idnproceeding

#%%timeit
#Get the last 200 records alone for testing purpose
data3 = data_refugee.tail(2000).copy()
subset = data3[data3["L1grant2"].isnull()].copy()
data2 = data3#.sort(["ij_code", "orderwithindayraw", "comp_date"])

for i, row in subset.iterrows():
    date = row['comp_date']
    ij_code = row['ij_court_code']
    order = row['orderwithindayraw']
                
    indices = data2[(data2.ij_court_code == ij_code) & 
      ((data2.comp_date < date) | ((data2.comp_date == date) & (data2.orderwithindayraw < order)))]
    if len(indices > 0):
        most_recent = indices["orderwithindayraw"][indices.comp_date == indices.comp_date.max()].idxmax(axis=1)
        most_recent_date = data2["comp_date"].loc[most_recent]
        if (date - most_recent_date) < 30:
            data3["L1grant2"].loc[i] = data2["grantraw"].loc[most_recent]
            data3["L1imputed"].loc[i] = 1

# Let's compare and make sure we got the same answers
print sum(data3['L1grant2'].isnull() & data['L1grant2'].notnull())
print sum(data3['L1grant2'].notnull() & data['L1grant2'].isnull())
print sum(data3['L1grant2'].notnull() & data['L1grant2'].notnull() & (data3['L1grant2'] != data['L1grant2']))

d_truth = data_refugee.tail(2000)

# Let's compare and make sure we got the same answers
print sum(data3['L1grant2'].isnull() & d_truth['L1grant2'].notnull())
print sum(data3['L1grant2'].notnull() & d_truth['L1grant2'].isnull())
print sum(data3['L1grant2'].notnull() & d_truth['L1grant2'].notnull() 
                & (data3['L1grant2'] != d_truth['L1grant2']))
                
sum(data3['L1grant2'].isnull())