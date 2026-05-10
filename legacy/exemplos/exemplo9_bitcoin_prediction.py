# %%
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sb
 
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import SVC
from xgboost import XGBClassifier 
from sklearn.metrics import confusion_matrix

#conda install -c conda-forge py-xgboost-gpu 
#conda install -c conda-forge xgboost
from sklearn import metrics

pd.set_option("display.max_rows", None, "display.max_columns", None)
pd.set_option('display.max_colwidth', None)


#%% 
import warnings
warnings.filterwarnings('ignore')
df = pd.read_csv('./data/btc1d_usdt.csv',index_col=0)
print(df.head())
print(df.shape)
print(df.describe())
print(df.info())

plt.figure(figsize=(15, 5))
plt.plot(df['close'])
plt.title('Bitcoin Close price.', fontsize=15)
plt.ylabel('Price in dollars.')
plt.show()

features =  ['open_time','open', 'high', 'low', 'close', 'volume', 'trades', 'volume_obv', 'trend_ema_fast', 
             'trend_ema_slow', 'momentum_rsi', 'momentum_stoch_rsi', 'others_cr', 'morningstar', 
             'hammer', 'piercing', '3soldiers', 'engulfing', 'ema200', 'ema50', 'slope', 'slope_obv']

print("Check if data is null:")
print(df[features].isnull().sum())

df = df[features].dropna(subset=features)

# %%
import seaborn as sns
# Create a pairplot to visualize the relationships
sns.pairplot(df[features[1:13]+features[18:]])
plt.title('Pairplot of Relevant Variables for BTC Price Movement')
plt.show()

# %%
features = ['open', 'high', 'low', 'close']
 
plt.subplots(figsize=(10,10))
for i, col in enumerate(features[1:]):
  plt.subplot(2,2,i+1)
  sb.distplot(df[col])
plt.show()
plt.subplots(figsize=(10,10))
for i, col in enumerate(features):
  range_min = 0.0
  range_max = 10000.0
  filtered_data = [x for x in df[col] if range_min <= x <= range_max]
  plt.subplot(2,2,i+1)
  sb.distplot(filtered_data)
plt.show()

#plt.subplots(figsize=(10,10))
# for i, col in enumerate(features):
#   plt.subplot(2,2,i+1)
#   ax = sb.boxplot(df[col])
#   q1, median, q3 = df[col].quantile([0.25, 0.5, 0.75])
#   label_text=f"25% : {q1:.2f}   median : {median:.2f}   75% : {q3:.2f}"
#   plt.text(20000, -0.35, label_text, fontsize=12)
#   IQR = q3 - q1
#   k = 1.5  # Adjust this value if needed
#   lower_fence = q1 - k * IQR
#   upper_fence = q3 + k * IQR
#   label_fence=f"Fence line : {upper_fence:.2f}"
#   plt.text(20000, -0.25, label_fence, fontsize=12)
# plt.show()

# %%
df['open_time'] = pd.to_datetime(df['open_time'])

df['year'] = df['open_time'].dt.year
df['month'] = df['open_time'].dt.month
df['day'] = df['open_time'].dt.day

print(df.head())

# %%
data_grouped = df.groupby('year').mean()
plt.subplots(figsize=(20,10))
for i, col in enumerate(['open', 'high', 'low', 'close']):
  plt.subplot(2,2,i+1)
  data_grouped[col].plot.bar()
  dataLabel = f"{col}"
  plt.text(3, 39000, dataLabel, fontsize=12)
plt.show()

df['is_quarter_end'] = np.where(df['month']%3==0,1,0)
print(df.head())
df['open-close']  = df['open'] - df['close']
df['low-high']  = df['low'] - df['high']
df['target'] = np.where(df['close'].shift(-1) > df['close'], 0, 1)
plt.pie(df['target'].value_counts().values, 
        labels=["Goes down", "Goes up"], autopct='%1.1f%%')
plt.show()

plt.figure(figsize=(10, 10))
 

# %%
# As our concern is with the highly
# correlated features only so, we will visualize
# our heatmap as per that criteria only.
sb.heatmap(df.corr() > 0.8, annot=True, cbar=False)
plt.show()

features = df[['open-close', 'low-high', 'is_quarter_end']]
target = df['target']
 
scaler = StandardScaler()
features = scaler.fit_transform(features)
 
X_train, X_test, y_train, y_test = train_test_split(
    features, target, test_size=0.1, random_state=2022)

print(X_train.shape, X_test.shape)

models = [LogisticRegression(), SVC(kernel='poly', probability=True), XGBClassifier(), 
          RandomForestClassifier(), DecisionTreeClassifier]
 
for i in range(3):
  models[i].fit(X_train, y_train)
  y_pred = models[i].predict(X_test)
  print(f'{models[i]} : ')
  print('Training Accuracy : ', metrics.roc_auc_score(y_train, models[i].predict_proba(X_train)[:,1]))
  print('Validation Accuracy : ', metrics.roc_auc_score(y_test, models[i].predict_proba(X_test)[:,1]))
  print(f"y_test {y_test.value_counts()}")
  print(f"y_pred: \n") # numpy array
  unique_values, counts = np.unique(y_pred, return_counts=True)
  print(unique_values, counts) 
  
  cm = confusion_matrix(y_test, y_pred)
  print(cm)


print('\n\n0 : Goes up')
print('1 : Goes down')
#############################################################################################
#                                     More variables                                        #
#############################################################################################
# %%
features = df[['open', 'high', 'low', 'close', 'volume', 'trades',
       'volume_obv', 'trend_ema_fast', 'trend_ema_slow', 'momentum_rsi',
       'momentum_stoch_rsi', 'others_cr', 'morningstar', 'hammer', 'piercing',
       '3soldiers', 'engulfing', 'ema200', 'ema50', 'slope', 'slope_obv',
       'year', 'month', 'day', 'is_quarter_end', 'open-close', 'low-high']]
target = df['target']
 
scaler = StandardScaler()
features = scaler.fit_transform(features)
 
X_train, X_test, y_train, y_test = train_test_split(
    features, target, test_size=0.1, random_state=2022)

print(X_train.shape, X_test.shape)

models = [LogisticRegression(), SVC(kernel='poly', probability=True), XGBClassifier(), 
          RandomForestClassifier(), DecisionTreeClassifier()]
 
for i in range(3):
  models[i].fit(X_train, y_train)
  y_pred = models[i].predict(X_test)
  print(f'{models[i]} : ')
  print('Training Accuracy : ', metrics.roc_auc_score(y_train, models[i].predict_proba(X_train)[:,1]))
  print('Validation Accuracy : ', metrics.roc_auc_score(y_test, models[i].predict_proba(X_test)[:,1]))
  print(f"y_test {y_test.value_counts()}")
  print(f"y_pred: \n") # numpy array
  unique_values, counts = np.unique(y_pred, return_counts=True)
  print(unique_values, counts) 
  
  cm = confusion_matrix(y_test, y_pred)
  print(cm)


print('\n\n0 : Goes up')
print('1 : Goes down')

# %%
########################################################################################################
#                                   Random Forest Classifier                                           #
########################################################################################################
features = df[['open', 'high', 'low', 'close', 'volume', 'trades',
       'volume_obv', 'trend_ema_fast', 'trend_ema_slow', 'momentum_rsi',
       'momentum_stoch_rsi', 'others_cr', 'morningstar', 'hammer', 'piercing',
       '3soldiers', 'engulfing', 'ema200', 'ema50', 'slope', 'slope_obv',
       'year', 'month', 'day', 'is_quarter_end', 'open-close', 'low-high']]
target = df['target']
 
scaler = StandardScaler()
features = scaler.fit_transform(features)
 
X_train, X_test, y_train, y_test = train_test_split(
    features, target, test_size=0.1, random_state=2022)

print(X_train.shape, X_test.shape)

model_rfc = RandomForestClassifier()
 
model_rfc.fit(X_train, y_train)
y_pred = model_rfc.predict(X_test)
print(f'{model_rfc} : ')
print('Training Accuracy : ', metrics.roc_auc_score(y_train, model_rfc.predict_proba(X_train)[:,1]))
print('Validation Accuracy : ', metrics.roc_auc_score(y_test, model_rfc.predict_proba(X_test)[:,1]))
print(f"y_test {y_test.value_counts()}")
print(f"y_pred: \n") # numpy array
unique_values, counts = np.unique(y_pred, return_counts=True)
print(unique_values, counts) 

cm = confusion_matrix(y_test, y_pred)
print(cm)


print('\n\n0 : Goes up')
print('1 : Goes down')

# %%
########################################################################################################
#                                   Random Forest Classifier                                           #
########################################################################################################
features = df[['open', 'high', 'low', 'close', 'volume', 'trades',
       'volume_obv', 'trend_ema_fast', 'trend_ema_slow', 'momentum_rsi',
       'momentum_stoch_rsi', 'others_cr', 'morningstar', 'hammer', 'piercing',
       '3soldiers', 'engulfing', 'ema200', 'ema50', 'slope', 'slope_obv',
       'year', 'month', 'day', 'is_quarter_end', 'open-close', 'low-high']]
target = df['target']
 
scaler = StandardScaler()
features = scaler.fit_transform(features)
 
X_train, X_test, y_train, y_test = train_test_split(
    features, target, test_size=0.1, random_state=2022)

print(X_train.shape, X_test.shape)

model_dt = DecisionTreeClassifier()
 
model_dt.fit(X_train, y_train)
y_pred = model_dt.predict(X_test)
print(f'{model_dt} : ')
print('Training Accuracy : ', metrics.roc_auc_score(y_train, model_dt.predict_proba(X_train)[:,1]))
print('Validation Accuracy : ', metrics.roc_auc_score(y_test, model_dt.predict_proba(X_test)[:,1]))
print(f"y_test {y_test.value_counts()}")
print(f"y_pred: \n") # numpy array
unique_values, counts = np.unique(y_pred, return_counts=True)
print(unique_values, counts) 

cm = confusion_matrix(y_test, y_pred)
print(cm)


print('\n\n0 : Goes up')
print('1 : Goes down')

# %%
########################################################################################################
#                                            XGBClassifier                                             #
########################################################################################################
features = df[['open', 'high', 'low', 'close', 'volume', 'trades',
       'volume_obv', 'trend_ema_fast', 'trend_ema_slow', 'momentum_rsi',
       'momentum_stoch_rsi', 'others_cr', 'morningstar', 'hammer', 'piercing',
       '3soldiers', 'engulfing', 'ema200', 'ema50', 'slope', 'slope_obv',
       'year', 'month', 'day', 'is_quarter_end', 'open-close', 'low-high']]
target = df['target']
 
scaler = StandardScaler()
features = scaler.fit_transform(features)
 
X_train, X_test, y_train, y_test = train_test_split(
    features, target, test_size=0.1, random_state=1)

print(X_train.shape, X_test.shape)

model_dt = XGBClassifier()
 
model_dt.fit(X_train, y_train)
y_pred = model_dt.predict(X_test)
print(f'{model_dt} : ')
print('Training Accuracy : ', metrics.roc_auc_score(y_train, model_dt.predict_proba(X_train)[:,1]))
print('Validation Accuracy : ', metrics.roc_auc_score(y_test, model_dt.predict_proba(X_test)[:,1]))
print(f"y_test {y_test.value_counts()}")
print(f"y_pred: \n") # numpy array
unique_values, counts = np.unique(y_pred, return_counts=True)
print(unique_values, counts) 

cm = confusion_matrix(y_test, y_pred)
print(cm)


print('\n\n0 : Goes up')
print('1 : Goes down')
# %%
#######################################################################################################
#                                            XGBClassifier Kfold                                      #
#######################################################################################################
from sklearn.model_selection import KFold

features = df[['open', 'high', 'low', 'close', 'volume', 'trades',
       'volume_obv', 'trend_ema_fast', 'trend_ema_slow', 'momentum_rsi',
       'momentum_stoch_rsi', 'others_cr', 'morningstar', 'hammer', 'piercing',
       '3soldiers', 'engulfing', 'ema200', 'ema50', 'slope', 'slope_obv',
       'year', 'month', 'day', 'is_quarter_end', 'open-close', 'low-high']]
target = df['target']
 
scaler = StandardScaler()
features = scaler.fit_transform(features)



kf = KFold(n_splits=5, shuffle=True, random_state=2022)

# Placeholder for storing results per fold
training_scores = []
validation_scores = []

for train_idx, test_idx in kf.split(features):
    X_train, X_test = features[train_idx], features[test_idx]
    y_train, y_test = target[train_idx], target[test_idx]

    model_dt = XGBClassifier()  # Use xgboost.XGBClassifier directly
    model_dt.fit(X_train, y_train)

    y_pred = model_dt.predict(X_test)

    training_scores.append(metrics.roc_auc_score(y_train, model_dt.predict_proba(X_train)[:,1]))
    validation_scores.append(metrics.roc_auc_score(y_test, model_dt.predict_proba(X_test)[:,1]))

    print(f"y_test {y_test.value_counts()}")
    print(f"y_pred: \n") 
    unique_values, counts = np.unique(y_pred, return_counts=True)
    print(unique_values, counts) 

    cm = confusion_matrix(y_test, y_pred) 
    print(cm)

# Summarize cross-validation results
print(f"Average Training Accuracy: {np.mean(training_scores):.4f}")
print(f"Average Validation Accuracy: {np.mean(validation_scores):.4f}") 