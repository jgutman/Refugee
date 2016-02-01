import pandas as pd
import numpy as np
import os
import sklearn.ensemble
import random

def split_train_test(train_out_loc, test_out_loc, processed_code_file,
                     judge_code_file = '/scratch/jg3862/asylum_clean_chicago_eoirstrictconsec3_1.csv',
                     train_percentage = .80, rnd_seed = 4850):

    raw_data = pd.read_csv(processed_code_file)
    judge_code_data = pd.read_csv(judge_code_file, low_memory=False)
    random.seed(rnd_seed)
    
    train_size = int(train_percentage * len(raw_data))
    judges = judge_code_data.groupby("ij_code")
    all_judges = list(judges.groups.keys())
    np.random.shuffle(all_judges)
    
    train_length = 0
    train_judges = []
    train_cases = []
    i = 0
    while train_length < train_size :
        judge = all_judges[i]
        i += 1
        size = len(judges.groups[judge])
        if (size + train_length) > train_size:
            break
        train_judges.append(judge)
        train_length += size
        train_cases.extend(judges.groups[judge])
    
    test_cases = list(set(raw_data.index).difference(set(train_cases)))
    train_data = raw_data.loc[train_cases]
    test_data = raw_data.loc[test_cases]
    
    train_data.to_csv(train_out_loc, index = False)
    test_data.to_csv(test_out_loc, index = False)

folder = "/home/jg3862/"
full_data = "refugee_full.csv"
subsets_dropped = ["refugee_full_countries_dropped",
					"refugee_full_judge_dropped",
					"refugee_full_time_series_dropped",
					"refugee_full_time_series_and_judge_dropped"]

split_train_test("train_all_features.csv", "test_all_features.csv", folder + full_data)

for file in subsets_dropped:
	split_train_test("train_"+file+".csv", "test_"+file+".csv", folder + file + ".csv")
	
