import pandas as pd
import numpy as np
from sklearn import linear_model
from sklearn import metrics

train = pd.read_csv("/scratch/jg3862/baseline_train.csv")
test = pd.read_csv("/scratch/jg3862/baseline_test.csv")

train.replace(-1*np.inf, -1000., inplace=True)
test.replace(-1*np.inf, -1000., inplace=True)

booleans = train.dtypes[train.dtypes == "bool"].index
train.dtypes[train.dtypes == "bool"]
test[booleans] = test[booleans].astype(float)

baseline = linear_model.LogisticRegression(penalty='l2')
baseline.fit(train.drop("grantraw", axis=1), train["grantraw"])
yhat_train = baseline.predict_proba(train.drop("grantraw", axis=1))
yhat_test = baseline.predict_proba(test.drop("grantraw", axis=1))

#auc_train = metrics.roc_auc_score(train["grantraw"], yhat_train)
#auc_test = metrics.roc_auc_score(test["grantraw"], yhat_test)
#print "AUC train: ", str(auc_train)
#print "AUC test: ", str(auc_test)

#accuracy_train = metrics.accuracy_score(train["grantraw"], yhat_train)
#accuracy_test = metrics.accuracy_score(test["grantraw"], yhat_test)
#print "accuracy train: ", str(accuracy_train)
#print "accuracy test: ", str(accuracy_test)

#f1_train = metrics.f1_score(train["grantraw"], yhat_train)
#f1_test = metrics.f1_score(test["grantraw"], yhat_test)
#print "F1 train: ", str(f1_train)
#print "F1 test: ", str(f1_test)

np.savetxt("baseline_train_pred_L2_lr.csv" , yhat_train, fmt='%0.4f', delimiter = ",")
np.savetxt("baseline_test_pred_L2_lr.csv", yhat_test, fmt='%0.4f', delimiter = ",")

#yhat_train = pd.DataFrame(yhat_train)
#yhat_test = pd.DataFrame(yhat_test)

#yhat_train.to_csv("/scratch/jg3862/baseline_train_pred_L2_logistic_regression.csv", index=False)
#yhat_test.to_csv("/scratch/jg3862/baseline_test_pred_L2_logistic_regression.csv", index=False)
