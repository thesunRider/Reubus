#######################################
# Input Example ::
# python CrimeTypePredict.py -lat 11.23 -long 76.3
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
parser.add_argument("-lat", "--Latitude", help="Input Latitude", default='10.5')
parser.add_argument("-long", "--Longitude", help="Input Longitude", default='76.1')
args = parser.parse_args()

try:
    knn = pickle.load(open('model.pkl', 'rb'))
    norm = pickle.load(open('norm.pkl', 'rb'))
    le = pickle.load(open('le.pkl', 'rb'))
    w = pickle.load(open('weight.pkl', 'rb'))
    #data = pd.read_csv("crime.csv")
    #demo = data.iloc[0:10000]
    # places = {}
    # for row in demo.values:
    #     if row[10] not in places.keys():
    #         places[row[10]] = list(row[10:12])
    # x = places[location]
    x = np.array([float(args.Latitude), float(args.Longitude)]).reshape(-1, 2)
    x = norm.transform(x)
    x = x.dot(w)
    y = knn.predict(x)
    y = le.inverse_transform(y)
    print("A crime of type (" + y[0] + ") has a possiblity in this locality")
except:
    pass
