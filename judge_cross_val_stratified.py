import pandas as pd
import numpy as np
import os

pwd = os.getcwd()
raw_data = pd.read_csv(pwd + '/../../asylum_clean_chicago_eoirstrictconsec3_1.csv', low_memory=False)
clean_data = pd.read_csv(pwd + '/../../refugee_full.csv')

subset_with_codes = raw_data[["ij_code"]]
split_by_ij_code = subset_with_codes.groupby("ij_code")
                             
for judge in split_by_ij_code.groups:
    cases = split_by_ij_code.groups[judge]
    train = clean_data[~clean_data.index.isin(cases)]
    test = clean_data.ix[cases]
    
    train.to_csv(pwd + "/train_by_judge_" + judge, index = True)
    test.to_csv(pwd + "/test_by_judge_" + judge, index = True)