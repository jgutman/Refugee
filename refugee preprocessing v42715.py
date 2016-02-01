import pandas as pd
import numpy as np
import os 
from sklearn import preprocessing
from matplotlib import pyplot as plt

raw_data = pd.read_csv(os.getcwd() + '/asylum_clean_chicago_eoirstrictconsec3_1.csv', low_memory=False)

nums = range(5,21)
colnames = ["numgrant_prev" + str(i) for i in nums] 
colnames = colnames + ["prev" + str(i) + "_dayslapse" for i in nums] 
colnames = colnames + ["numcourtgrant_prev" + str(i) for i in nums] 
colnames = colnames + ["numcourtgrantself_prev" + str(i) for i in nums] 
colnames = colnames + ["numcourtdecideself_prev" + str(i) for i in nums] 
colnames = colnames + ["courtprev" + str(i) + "_dayslapse" for i in nums] 
colnames = colnames + ["numcourtgrantother_prev" + str(i) for i in nums] 
colnames = colnames + ["courtprevother" + str(i) + "_dayslapse" for i in nums]

avgnames = ["judge", "judgenat", "judgedef", "judgenatdef", "judgelawyer"]
keep = ["lomeangrantraw_", "numdecisionsraw_", "numdecisions"] 
drop = ["meangrant_", "lomeangrant_", "meangrantraw_"] 
keepnames = [i + j for i in keep for j in avgnames] 
dropnames = [i + j for i in drop for j in avgnames]

avgbyyear = ["", "nat", "natdef"] 
yearnames = ["judgenumdec" + i + "year" for i in avgbyyear] 
yearnames = yearnames + ["lojudgemean" + i + "year" for i in avgbyyear]

identifiers = ["idncase", "idnproceeding", "eoirattyid", "alienattyid", "hearing_loc_code", 
				"LastName", "FirstName", "OtherLocationsMentioned", "IJ_NAME", "Judge_name_SLR", 
				"famcode"] 
categorical = ["ij_code", "natid", "courtid", "comp_dow"] 
interactions = ["ij_court_code", "natcourtcode", "natdefcode", "natdefcourtcode"] 
duplicates = ["orderwithinday","L1grant", "L2grant", "moderategrant3070", "judgemeanyear", 
				"judgemeannatyear", "judgemeannatdefyear", "grantgrant", "grantdeny", 
				"denygrant", "denydeny", "Gender"] + dropnames 
averages = keepnames + yearnames 
alternative_targets = ["grant2", "grant"] 
target = "grantraw" 
unhelpful = ["order_raw", "min_osc_date", "max_osc_date", "min_input_date", 
				"max_input_date", "negoutliermeanyear", "negoutliermeannatyear", 
				"negoutliermeannatdefyear"] 
flag_variables = ["flag_decisionerror_strdes", "flag_decisionerror_idncaseproc", 
					"flag_earlystarttime", "flag_mismatch_base_city", "flag_mismatch_hearing", 
					"flag_multiple_proceedings", "flag_notfirstproceeding", "flag_notfirstproceeding2", 
					"flag_multiple_proceedings2", "flag_prevprocgrant", "flag_prevprocdeny", 
					"flag_unknowntime", "flag_unknownorderwithinday"] 
time_series = ["L1grant_sameday", "L2grant_sameday", "L1grant2", "L2grant2"] + colnames 
data = raw_data.drop(identifiers + duplicates + alternative_targets + unhelpful + interactions, axis=1)