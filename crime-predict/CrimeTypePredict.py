#######################################
# Input Example ::
# python CrimeTypePredict.py -p 9XX TERMINAL AVE
# places example :::
# 9XX NICOLA ST
# 12XX ALBERNI ST
# 11XX HARO ST

import numpy as np
import pickle
import pandas as pd
import argparse
parser = argparse.ArgumentParser()

# Adding optional argument
parser.add_argument("-p", "--Place", help="Input Place", default='9XX TERMINAL AVE')
args = parser.parse_args()

try:
    knn = pickle.load(open('model.pkl', 'rb'))
    norm = pickle.load(open('norm.pkl', 'rb'))
    le = pickle.load(open('le.pkl', 'rb'))
    w = pickle.load(open('weight.pkl', 'rb'))

    data = pd.read_csv("crime.csv")
    demo = data.iloc[0:10000]
    places = {}
    for row in demo.values:
        if row[6] not in places.keys():
            places[row[6]] = list(row[10:12])

    location = args.Place
    x = places[location]
    x = np.array(x).reshape(-1, 2)
    x = norm.transform(x)
    x = x.dot(w)
    y = knn.predict(x)
    y = le.inverse_transform(y)
    print("A crime of type (" + y[0] + ") has a possiblity in this locality")
except e:
    pass
