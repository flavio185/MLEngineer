# Importing important libraries

# For data cleaning 
import pandas as pd
import numpy as np
import ssl
from joblib import dump

# For preprocessing and building model
from sklearn.svm import SVR
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder


def importDataSet():
  ssl._create_default_https_context = ssl._create_unverified_context
  url = 'https://raw.githubusercontent.com/flavio185/MLEngineer/main/salary_case/ds_salaries.csv'
  dataset = pd.read_csv(url)
  return dataset

df = importDataSet()

# Drop unecessary columns
df.drop(["Unnamed: 0", "salary"], axis = 1, inplace = True)

df["work_year"] = df["work_year"].astype("str")

# Renaming columns entries for clarity

# Experience Level
df["experience_level"] = df["experience_level"].map({"SE":"Senior", "MI":"Junior", "EN":"Entry", "EX":"Expert"})
# # Employment Type
df["employment_type"] = df["employment_type"].map({"FT":"Full-time", "PT":"Part-time", "CT":"Contract", "FL":"Freelance"})
# # Remote Ratio
df["remote_ratio"] = df["remote_ratio"].map({0:"Onsite", 50:"Hybrid", 100:"Remote"})
# Company Size
df["company_size"] = df["company_size"].map({"S":"Small", "M":"Medium", "L":"Large"})

###PRE PROCESSING

X = df.copy()
y = X.pop("salary_in_usd")

X.drop(["salary_currency", "company_location"], axis = 1, inplace = True)


##Split Categorical data into OneHotEncoder and LabelEncoder

X_nominal_data = X[["work_year", "job_title", "remote_ratio", "employee_residence"]].reset_index(drop=True)

X_ordinal_data = X[["experience_level", "employment_type", "company_size"]].reset_index(drop=True)
X_ordinal_data["experience_level"] = X_ordinal_data["experience_level"].map({"Entry":1, "Junior":2, "Senior":3, "Expert":4})
X_ordinal_data["employment_type"] = X_ordinal_data["employment_type"].map({"Freelance":1, "Contract":2, "Part-time":3, "Full-time":4})
X_ordinal_data["company_size"] = X_ordinal_data["company_size"].map({"Small":1, "Medium":2, "Large":3})

enc = OneHotEncoder(drop="first")

enc.fit(X_nominal_data)

X_onehotencoded = enc.transform(X_nominal_data).toarray()
X_onehotencoded = pd.DataFrame(X_onehotencoded)



X = pd.concat([X_onehotencoded, X_ordinal_data], axis=1)

###Training
X_train, X_valid, y_train, y_valid = train_test_split(X, y, train_size = 0.8, test_size = 0.2, random_state = 1)

# Using SVR that has the lowest MAE
svr = SVR()

model = SVR(C = 1, gamma = 1, kernel = "poly")
model.fit(X_train, y_train)
#preds = model.predict(X_valid[:1])

dump(model, 'model.joblib') # save the model
dump(enc, 'encoder.joblib') # save the encoder