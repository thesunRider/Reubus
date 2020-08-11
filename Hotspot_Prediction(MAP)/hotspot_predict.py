#######################################
# Input Example ::
# python hotspot_predict.py -lat 11.05 -long 76.1 -rad 0.2 -hpts 5
#######################################

import pandas as pd
from sklearn.preprocessing import MinMaxScaler
import numpy as np
import math
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, LSTM
from tensorflow.keras.callbacks import ModelCheckpoint
from sklearn.metrics import mean_squared_error
import pickle
import argparse
parser = argparse.ArgumentParser()
import tensorflow as tf
# print(tf.__version__)
parser.add_argument("-lat", "--Latitude", help="Input Latitude", default=11.05)
parser.add_argument("-long", "--Longitude", help="Input Longitude", default=76.1)
parser.add_argument("-rad", "--Radius", help="Input Radius", default=0.2)
parser.add_argument("-hpts", "--Hotspots", help="Input Hotspots", default=5)
args = parser.parse_args()

loca = pd.read_csv('locations_Kerala.csv')


def isInside(circle_x, circle_y, rad, x, y):
    if ((x - circle_x) * (x - circle_x) + (y - circle_y) * (y - circle_y) <= rad * rad):
        return True
    else:
        return False


def create_dataset(dataset, window_size=1):
    data_X, data_Y = [], []
    for i in range(len(dataset) - window_size):
        a = dataset[i:(i + window_size), :]
        data_X.append(a)
        data_Y.append(dataset[i + window_size, :])
    return(np.array(data_X), np.array(data_Y))


def create_model():
    model = Sequential()
    model.add(LSTM(8, input_shape=(2, window_size), return_sequences=True))
    model.add(LSTM(4, input_shape=(2, window_size)))
    model.add(Dense(2))
    return model


locations = []

circle_x = 11.05
circle_y = 76.1
rad = 0.2

circle_x = float(args.Latitude)
circle_y = float(args.Longitude)
rad = float(args.Radius)

for row in loca.values:
    x = row[4]
    y = row[5]
    if(isInside(circle_x, circle_y, rad, x, y)):
        locations.append(row[0])
# long 77.28 - 74.88
# lat 12.78 - 8.31

data = {}
for num in range(1000):
    i = np.random.randint(0, len(locations))
    data[num] = [i, np.mean(loca['Lat'].loc[loca['Name'] == locations[i]]), np.mean(loca['Long'].loc[loca['Name'] == locations[i]])]

df = pd.DataFrame.from_dict(data, orient='index', columns=['place', 'lat', 'lon'])
df.to_csv('hotspots_fake_data.csv', header=True, index=False)

lat_scaler = MinMaxScaler(feature_range=(0, 1))
long_scaler = MinMaxScaler(feature_range=(0, 1))

lat_x = lat_scaler.fit_transform(df.iloc[:, 1].values.reshape(-1, 1))
long_x = long_scaler.fit_transform(df.iloc[:, 2].values.reshape(-1, 1))

x = np.concatenate((lat_x, long_x), axis=1)

size = 0.80
train_size = int(len(x) * size)
test_size = len(x) - train_size
train, test = x[0:train_size, :], x[train_size:len(x), :]

window_size = 5
train_X, train_Y = create_dataset(train, window_size)
test_X, test_Y = create_dataset(test, window_size)

train_X = train_X.transpose(0, 2, 1)
test_X = test_X.transpose(0, 2, 1)


ckpt_model = 'model.hdf5'
checkpoint = ModelCheckpoint(ckpt_model, monitor='loss', verbose=0, save_best_only=True, mode='min')
callbacks_list = [checkpoint]
model = create_model()
model.compile(loss="mean_squared_error", optimizer="adam", metrics=['mean_absolute_error'])
model.fit(train_X, train_Y, epochs=2, batch_size=1, verbose=0, callbacks=callbacks_list)


def predict_and_score(X, Y):
    pred = model.predict(X)
    score = math.sqrt(mean_squared_error(Y, pred))
    return(score, pred)


rmse_train, train_predict = predict_and_score(train_X, train_Y)
rmse_test, test_predict = predict_and_score(test_X, test_Y)

pickle.dump(lat_scaler, open('lat_scaler.pkl', 'wb'))
pickle.dump(long_scaler, open('long_scaler.pkl', 'wb'))

df = pd.read_csv('hotspots_fake_data.csv')
window_size = 5

model = create_model()
model.load_weights('model.hdf5')

lat_scaler = pickle.load(open('lat_scaler.pkl', 'rb'))
long_scaler = pickle.load(open('long_scaler.pkl', 'rb'))

x_lat = lat_scaler.fit_transform(df.iloc[-5:, 1].values.reshape(-1, 1))
x_long = long_scaler.fit_transform(df.iloc[-5:, 2].values.reshape(-1, 1))

hotspots = int(args.Hotspots)
for i in range(hotspots):
    x_la = x_lat[-5:].reshape(-1, 1)
    x_lo = x_long[-5:].reshape(-1, 1)
    x = np.concatenate((x_la, x_lo), axis=1)
    im = []
    im.append(x)
    x = np.array(im)
    x = x.transpose(0, 2, 1)
    result = model.predict(x)
    res_lat = lat_scaler.inverse_transform(result[0][0].reshape(-1, 1))
    res_long = long_scaler.inverse_transform(result[0][1].reshape(-1, 1))
    print('('+str(res_lat[0][0])+','+str(res_long[0][0])+')')
    x_lat = np.concatenate((x_lat, res_lat), axis=0)
    x_long = np.concatenate((x_long, res_long), axis=0)
