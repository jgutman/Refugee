import pandas as pd
import numpy as np
import os

data = pd.read_csv(os.getcwd() + '/asylum_clean_chicago_eoirstrictconsec3_1.csv', low_memory=False)
country_codes = pd.read_csv(os.getcwd() + '/nat.csv')
data_truncated = data[['idncase', 'grantraw', 'natid', 'comp_date', 'year']]
data_truncated = data_truncated.dropna(axis=0, subset=['natid']) # drop rows where natid=nan

country_dict = {code: name for code, name in zip(country_codes['natid'], country_codes['nat_string'])}
data_truncated['country_name'] = [country_dict[id] for id in data_truncated['natid']]

# Top 15 countries for asylum seekers across all years
data_truncated['country_name'].value_counts()[:15]

# Top 15 countries for asylum seekers year by year
for year in range(1985, 2014):
    print ('Year : %s' %year)
    print data_truncated[data_truncated['year']==year]['country_name'].value_counts()[:15]