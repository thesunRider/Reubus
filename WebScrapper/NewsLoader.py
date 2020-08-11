#######################################
# Input Example ::
# python NewsLoader.py -fd 07/01/2020 -td 07/03/2020 -p Kochi -k theft

# Place name start with capital letter
# date format MM/DD/YYYY

# Date : use date picker in Autoit
# Place : use Drop box in Autoit

import argparse
from datetime import datetime
import datetime as dt
import pandas as pd
import numpy as np
import json

# Initialize parser
parser = argparse.ArgumentParser()

# Adding optional argument
parser.add_argument("-fd", "--FromDate", help="Input Start Date", default=None)
parser.add_argument("-td", "--ToDate", help="Input End Date", default=None)
parser.add_argument("-p", "--Place", help="Input Place", default='All')
parser.add_argument("-k", "--Keyword", help="Input Keywords", default='All')
args = parser.parse_args()

print("Diplaying Output as:", args.Place)

# Open the CSV files
news = pd.read_csv('news_feed.csv')
places = pd.read_csv('locations_Kerala.csv')

mask = True

from_date = args.FromDate
to_date = args.ToDate
if from_date and to_date:
    from_date = datetime.strptime(from_date, '%m/%d/%Y')
    print("Diplaying Output as:", str(from_date.date()))
    to_date = datetime.strptime(to_date, '%m/%d/%Y')
    print("Diplaying Output as:", str(to_date.date()))
    mask = mask & (news['Date'] > str(from_date)) & (news['Date'] <= str(to_date + dt.timedelta(days=1)))

if args.Place != 'All':
    mask = mask & (news['Place'] == args.Place)

if args.Keyword != 'All':
    print("Diplaying Output as:", args.Keyword)
    key_list = args.Keyword.split(',')
    key_mask = False
    for i in key_list:
        key_mask = key_mask | (news['Keywords'].apply(lambda x: i in x))
    mask = mask & key_mask

# print(news.loc[mask].values)
data = []
for row in news.values:
    data.append({'date': row[0], 'place': row[1], 'summary': row[2], 'keyword': row[3]})

with open("result1.json", "w") as write_file:
    json.dump(data, write_file)

with open("result1.json", "r") as read_file:
    decodedArray = json.load(read_file)
    print(np.asarray(decodedArray))
