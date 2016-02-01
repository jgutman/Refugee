import pandas as pd
import numpy as np
import os
from sklearn import preprocessing
from matplotlib import pyplot as plt

from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.ensemble import AdaBoostClassifier

raw_data = pd.read_csv(os.getcwd() + '/../../asylum_clean_chicago_eoirstrictconsec3_1.csv', low_memory=False)
clean_data = pd.read_csv(os.getcwd() + '/../../refugee_data_post_processing_v2.csv')

subset_with_codes = raw_data[["ij_code", "ij_court_code", "grantraw"]]
split_by_ij_code = subset_with_codes.groupby("ij_code")

clean_data.replace(-1*np.inf, -1000., inplace=True)

judge_errors = pd.DataFrame(index = split_by_ij_code.groups.keys(), 
                            columns = ["observed grants", "expected grants", "false positives", 
                                       "false negatives", "errors"])

#i = 0                                       
for judge in split_by_ij_code.groups:
    #i += 1
    #if i > 10: break
    cases = split_by_ij_code.groups[judge]
    train = clean_data[~clean_data.index.isin(cases)]
    test = clean_data.ix[cases]
    
    model = RandomForestClassifier(n_estimators=50)
    #model = AdaBoostClassifier(DecisionTreeClassifier(max_depth=1), n_estimators=50)
    X = train.drop("grantraw", axis=1)
    y = train["grantraw"]
    model.fit(X,y)
    hard_classification = model.predict(test.drop("grantraw", axis=1))
    actual = test["grantraw"]
    predicted = pd.Series(hard_classification, index = test.index)
    judge_errors["observed grants"][judge] = sum(actual)
    judge_errors["expected grants"][judge] = sum(predicted)
    
    judge_errors["false positives"][judge] = sum((actual == 0) & (predicted == 1))
    judge_errors["false negatives"][judge] = sum((actual == 1) & (predicted == 0))
    judge_errors["errors"][judge] = judge_errors["false positives"][
                            judge] + judge_errors["false negatives"][judge]
                            
judge_errors.to_csv(os.getcwd() + "/judge_by_judge_random_forest.csv", index = True)
#judge_errors.to_csv(os.getcwd() + "/judge_by_judge_adaboost.csv", index = True)
print(os.getcwd() + "/judge_by_judge_random_forest.csv")
