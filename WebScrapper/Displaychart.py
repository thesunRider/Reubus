import pandas as pd
import numpy as np
from datetime import datetime
import matplotlib.pyplot as plt

news = pd.read_csv('news_feed.csv')
places = pd.read_csv('locations_Kerala.csv')

calender = {1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'}


def kerala_top_keywords_chart(df):
    key = {}
    for row in df.values:
        for i in row[3][1:-1].split(','):
            if i[2:-1] in key.keys():
                key[i[2:-1]] += 1
            else:
                key[i[2:-1]] = 1
    key = {k: v for k, v in sorted(key.items(), key=lambda item: item[1], reverse=True)}

    labels = ['death', 'murder', 'vehicle', 'killed', 'accident', 'blackmail', 'theft', 'rape', 'lost', 'missing']
    values = []
    for i in labels:
        values.append(key[i])
    fig = plt.figure(figsize=(10, 5))
    plt.bar(labels, values, color='green', width=0.3)
    plt.xlabel("Keywords", fontsize=12)
    plt.ylabel("No.of Occurances", fontsize=12)
    plt.title("Top keywords in Kerala", fontsize=18)
    plt.savefig('chart3.png')


def top_crime_reports_place(df):
    place = {}
    for row in df.values:
        if row[1] in place.keys():
            place[row[1]] += 1
        else:
            place[row[1]] = 1
    place = {k: v for k, v in sorted(place.items(), key=lambda item: item[1], reverse=True)}

    labels = list(place.keys())[:10]
    values = list(place.values())[:10]
    fig = plt.figure(figsize=(10, 5))
    plt.barh(labels, values, color='blue', height=0.3)
    plt.ylabel("Places", fontsize=12)
    plt.yticks(rotation=20)
    plt.tick_params(labelsize=9)
    plt.xlabel("No.of Crimes reported", fontsize=12)
    plt.title("Top Crime reported Placess", fontsize=18)
    fig.subplots_adjust(left=0.2)
    plt.savefig('chart2.png')


def monthly_stats(df):
    time = {}
    for row in df.values:
        new = datetime.strptime(row[0], '%Y-%m-%d %H:%M:%S')
        new = str(calender[new.month]) + '-' + str(new.year)
        if new in time.keys():
            time[new] += 1
        else:
            time[new] = 1
    labels = list(time.keys())[:12]
    values = list(time.values())[:12]
    fig = plt.figure(figsize=(10, 5))
    plt.bar(labels, values, color='red', width=0.3)
    plt.xlabel("Month", fontsize=12)
    plt.xticks(rotation=10)
    plt.tick_params(labelsize=8)
    plt.ylabel("No.of Occurances", fontsize=12)
    plt.title("Top Monthly Crimes in Kerala", fontsize=16)
    plt.savefig('chart1.png')


kerala_top_keywords_chart(news)

top_crime_reports_place(news)

monthly_stats(news)
