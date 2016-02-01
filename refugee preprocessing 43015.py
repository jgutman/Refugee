import pandas as pd
import numpy as np

import os
import datetime

from sklearn import preprocessing
from matplotlib import pyplot as plt

# Large dataset, this line can take a little bit of time to run (about 30 seconds)
raw_data = pd.read_csv(os.getcwd() + '/asylum_clean_chicago_eoirstrictconsec3_1.csv', low_memory=False)

# Let's group all the time series features with x out of the prev 5-20 decisions
nums = range(5,21)
colnames = ["numcourtgrant_prev" + str(i) for i in nums]
colnames = colnames + ["numcourtgrantself_prev" + str(i) for i in nums]
colnames = colnames + ["numcourtdecideself_prev" + str(i) for i in nums]
colnames = colnames + ["courtprev" + str(i) + "_dayslapse" for i in nums]

# Some of the features only go from 5-10 instead of 5-20
nums = range(5,11)
colnames = colnames + ["prev" + str(i) + "_dayslapse" for i in nums]
colnames = colnames + ["numcourtgrantother_prev" + str(i) for i in nums]
colnames = colnames + ["courtprevother" + str(i) + "_dayslapse" for i in nums]
colnames = colnames + ["numgrant_prev" + str(i) for i in nums]

# Let's take all the features that refer to averages over a given subset of decisions
# lomeangrant is the average over all decisions in the subset where the current decision is not included in the mean
# we want to throw away the meangrant (which includes the current decision)
# and also get rid of all avgs not based on grantraw
avgnames = ["judge", "judgenat", "judgedef", "judgenatdef", "judgelawyer"]
keep = ["lomeangrantraw_", "numdecisionsraw_", "numdecisions"]
drop = ["meangrant_", "lomeangrant_", "meangrantraw_"]

keepnames = [i + j for i in keep for j in avgnames]
dropnames = [i + j for i in drop for j in avgnames]

# Same goes for the averages in a given year
avgbyyear = ["", "nat", "natdef"]
yearnames = ["judgenumdec" + i + "year" for i in avgbyyear]
yearnames = yearnames + ["lojudgemean" + i + "year" for i in avgbyyear]

# DateofAppointment comes in all different formats so let's transform the dates to a datetime object
raw_data["DateofAppointment_formatted"] = raw_data["DateofAppointment"]
for datestring in pd.unique(raw_data["DateofAppointment"][raw_data["DateofAppointment"].notnull()]):
    try: 
        date = datetime.datetime.strptime(datestring, "%d%b%Y").date()
    except ValueError:
        if datestring[3] == "-":
            date = datetime.datetime.strptime(datestring, "%b-%y").date()
        else:
            date = datetime.datetime.strptime(datestring, "%b %y").date()
    raw_data["DateofAppointment_formatted"][raw_data["DateofAppointment"] == datestring] = date

# comp_date is given in number of days since January 1, 1960, so let's also transform this to a datetime object
dates_available = raw_data["comp_date"][raw_data["comp_date"].notnull()]  
raw_data["comp_date_formatted"] = raw_data["comp_date"]
raw_data["comp_date_formatted"] = [datetime.date(1960, 1, 1) + datetime.timedelta(i) for i in dates_available]

# Now let's create a numeric feature that gives the number of days since the judge's appointment 
# up to the current decision, nan if DateofAppointment is missing for that judge
subset = raw_data[raw_data["comp_date_formatted"].notnull() & raw_data["DateofAppointment_formatted"].notnull()]
timediff = [(a-b).days for (a,b) in zip(subset["comp_date_formatted"], subset["DateofAppointment_formatted"])]
raw_data["TimeSinceAppointment"] = np.nan * np.zeros(len(raw_data))
raw_data["TimeSinceAppointment"][raw_data["comp_date_formatted"].notnull() 
                                 & raw_data["DateofAppointment_formatted"].notnull()] = timediff
                                 
# These are mostly unique identifiers and we wouldn't want to include them in the model
identifiers = ["idncase", "idnproceeding", "eoirattyid", "alienattyid", "hearing_loc_code", 
              "LastName", "FirstName", "IJ_NAME", "Judge_name_SLR", "famcode",
              "judge_name_caps", "ij_code"]
# Need to transform to sets of indicator variables with sklearn.preprocessing
categorical = ["natid", "courtid", "comp_dow"]
# Note that we've taken certain judge-level identifiers including ij_code, "FirstUndergrad", "LawSchool",
# "Bar", "Court_SLR" out of the data because they are categorical variables with too many levels, 
# and because we would like to be able to make predictions on new judges not in the data set

# Variables related to the biographical info we have on each judge, missing for about 5% of cases
# Overall I am a little skeptical about the quality of this data
judge_vars = ["Male_judge", "TimeSinceAppointment",
             "Year_Appointed_SLR", "Year_College_SLR", "Year_Law_school_SLR", "President_SLR", 
             "Government_Years_SLR", "Govt_nonINS_SLR", "INS_Years_SLR", "Military_Years_SLR", "NGO_Years_SLR",
             "Privateprac_Years_SLR", "Academia_Years_SLR", "experience", "experience8", "log_experience", 
             "log_gov_experience", "log_INS_experience", "log_military_experience", "log_private_experience",
             "log_academic_experience", "govD", "INSD", "militaryD", "privateD", "academicD", "democrat"]
# These are mostly interactions of already included categorical variables, so we don't want to include them
interactions = ["ij_court_code", "natcourtcode", "natdefcode", "natdefcourtcode"]
# These essentially duplicate other variables already contained within the model, often based on less complete
# information, (i.e. based on grant rather than grantraw)
duplicates = ["orderwithinday","L1grant", "L2grant", "moderategrant3070", "judgemeanyear", "judgemeannatyear", 
              "judgemeannatdefyear", "grantgrant", "grantdeny", "denygrant", "denydeny", "Gender", 
             "republican", "DateofAppointment", "comp_date_formatted", "DateofAppointment_formatted", 
             "YearofFirstUndergradGraduatio", "INS_Every5Years_SLR", "afternoon"] + dropnames
# Information about average grant rate for particular subsets of the data
averages = keepnames + yearnames
# Important to exclude these or we will have major leakage
alternative_targets = ["grant2", "grant"]
# grantraw differs from grant in that grant is NA when orderwithinday is unknown (see flag_unknownorderwithinday)
target = "grantraw"
unhelpful = ["order_raw", "min_osc_date", "max_osc_date", "min_input_date", "max_input_date", 
             "negoutliermeanyear", "negoutliermeannatyear", "negoutliermeannatdefyear", "OtherLocationsMentioned",
            "JudgeUndergradLocation", "JudgeLawSchoolLocation", "FirstUndergrad", "LawSchool",
            "Bar", "Court_SLR"]
flag_variables = ["flag_decisionerror_strdes", "flag_decisionerror_idncaseproc", "flag_earlystarttime", 
                  "flag_mismatch_base_city", "flag_mismatch_hearing", "flag_multiple_proceedings",
                 "flag_notfirstproceeding", "flag_notfirstproceeding2", "flag_multiple_proceedings2",
                 "flag_prevprocgrant", "flag_prevprocdeny", "flag_unknowntime", "flag_unknownorderwithinday"]
time_series = ["L1grant_sameday", "L2grant_sameday", "L1grant2", "L2grant2"] + colnames

data = raw_data.drop(identifiers + duplicates + alternative_targets + unhelpful + interactions, axis=1)
data["morning"][data["hour_start"].isnull()] = np.nan
data["lunchtime"][data["hour_start"].isnull()] = np.nan

# Transform all the categorical variables into sets of indicator variables and drop the original
data2 = data.copy()
for feature in categorical:
    dummies = pd.get_dummies(data2[feature], feature, dummy_na=True)
    data2 = pd.concat([data2, dummies], axis = 1)    
data2 = data2.drop(categorical, axis=1)

# Let's make sure that the number of columns is less than the square root of n where n is the size of our training set
len(data2.columns) < np.sqrt(len(data2) * .80)

# TODO add in data for country of origin

data3 = data2.drop(time_series, axis=1)
missing = np.sum(pd.isnull(data3))
missing.sort(ascending=False)
missing[missing > 0]

col_names = ["lojudgemeannatdefyear", "difmeannatdefyear", "outliermeannatdefyear", 
             "absdifmeannatdefyear", "lojudgemeannatyear", "difmeannatyear", 
             "outliermeannatyear", "absdifmeannatyear"]
means = data3[col_names].mean()
for i in col_names:
    data3[i][data3[i].isnull()] = means[i]
    
