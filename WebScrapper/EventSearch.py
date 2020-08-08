#######################################
# Input Example ::
# python EventSearch.py gold smuggling


import sys
import json
import requests
import argparse
from newspaper import Article
from bs4 import BeautifulSoup

live_updates = {}
if sys.argv[1:]:
    q_string = ''
    for i in sys.argv[1:]:
        q_string += i + '+'
    q_string = q_string[:-1]
    url = 'https://www.google.co.in/search?q=' + q_string + '&source=lnt&tbm=nws&tbs=sbd:1&hl=en&start=0'
    USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:65.0) Gecko/20100101 Firefox/65.0"
    headers = {"user-agent": USER_AGENT}
    # resp = requests.get(URL, headers=headers)
    res = requests.get(url, headers=headers)
    # res.raise_for_status()
    soup = BeautifulSoup(res.text, 'html.parser')
    headline = soup.find("div", {'id': 'search'})
    # print(headline.text)
    # print(headline.find_all("div", {'class': 'dbsr'}))
    for i in headline.find_all("div", {'class': 'dbsr'}):
        for j in i.find_all('a'):
            if j.get('href'):
                try:
                    article = Article(j.get('href'), 'en')
                    article.download()
                    article.parse()
                    live_updates[j.get('href')] = article.title
                except Exception as e:
                    pass

with open("result2.json", "w") as write_file:
    json.dump(live_updates, write_file)

with open("result2.json", "r") as read_file:
    decoded = json.load(read_file)
    print(decoded)
