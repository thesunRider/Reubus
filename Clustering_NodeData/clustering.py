import numpy as np
import pandas as pd
from kmodes.kmodes import KModes
import matplotlib.pyplot as plt
from sklearn.preprocessing import LabelEncoder
import seaborn as sns
from collections import defaultdict

df = pd.read_csv("temp_data.csv")
df_copy = df.copy()
# le = preprocessing.LabelEncoder()
d = defaultdict(LabelEncoder)
df = df.apply(lambda x: d[x.name].fit_transform(x))
array = df.values[:, 1:]
cost = []
for num_clusters in list(range(1, 4)):
    kmode = KModes(n_clusters=num_clusters, init="Cao", n_init=1, verbose=2)
    kmode.fit_predict(array)
    cost.append(kmode.cost_)
y = np.array([i for i in range(1, 4)])
plt.plot(y, cost)
plt.show()
km_cao = KModes(n_clusters=2, init="Cao", n_init=1, verbose=2)
clusters = km_cao.fit_predict(array)
print(km_cao.cluster_centroids_)
df = df_copy.reset_index()
clustersDf = pd.DataFrame(clusters)
clustersDf.columns = ['cluster_predicted']
combinedDf = pd.concat([df, clustersDf], axis=1).reset_index()
combinedDf = combinedDf.drop(['index', 'level_0'], axis=1)
print(combinedDf.head())
data = {
    0: [1, 'None', 'None', 'None', 'None']
}
test_df = pd.DataFrame.from_dict(data, orient='index', columns=df_copy.columns)
print(test_df.head())
test_df = test_df.apply(lambda x: d[x.name].transform(x))
test_array = test_df.values[:, 1:]
print(test_array)
print(km_cao.predict(test_array))
