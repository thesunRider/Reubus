import nltk
import requests
import pandas as pd
from bs4 import BeautifulSoup
from newspaper import Article
from datetime import datetime
nltk.download('punkt')
news = pd.read_csv('news_feed.csv')
recent = news.iloc[0, 0]
print(news.head())
recent = datetime.strptime(recent, '%Y-%m-%d %H:%M:%S')

links = []
url = 'https://english.mathrubhumi.com/news/crime-beat'
page = requests.get(url).text
soup = BeautifulSoup(page)
headline = soup.find("div", {"class": "row listPg-md7-rw"})
for i in headline.find_all('a'):
  if i.get('href'):
    links.append(i.get('href'))
data = {}
count = 0
for i in links:
  urls = 'https://english.mathrubhumi.com/' + i
  page = requests.get(urls).text
  soup = BeautifulSoup(page)
  headline = soup.find("div", {"class": "common_text_en date_outer"})
  if headline:
    date = headline.get_text().strip()
    date_time = datetime.strptime(date[:-4], '%b %d, %Y, %I:%M %p')
    parag = soup.find("div", {"class": "articleBody common_text"})
    para = parag.find_all('p')
    place = para[0].get_text().split(':')[0]
    if date_time > recent:
      article = Article(urls, 'en')
      article.download()
      article.parse()
      article.nlp()
      summary = article.summary
      data[count] = [date_time, place, summary, article.keywords]
      count += 1

links = []
url = 'https://www.onmanorama.com/districts/'
districts = ['alappuzha', 'ernakulam', 'idukki', 'kannur', 'kasaragod', 'kollam',
             'kottayam', 'kozhikode', 'malappuram', 'palakkad', 'pathanamthitta',
             'thiruvananthapuram', 'thrissur', 'wayanad']
for d in districts:
  urls = url + d + '.html'
  page = requests.get(urls).text
  soup = BeautifulSoup(page)
  headline = soup.find("div", {"class": "articlelisting section"})
  for i in headline.find_all('a'):
    site = i.get('href')
    if site and site not in links:
      date = site.replace(url + d + '/', "")
      date = date[:10]
      date = datetime.strptime(date, '%Y/%m/%d')
      if date > recent:
        links.append(site)
for i in links:
  urls = i
  page = requests.get(urls).text
  soup = BeautifulSoup(page)
  headline = soup.find("time", {"class": "story-author-date"})
  date_time_str = headline.get_text()
  date_time = datetime.strptime(date_time_str[:-4], '%B %d, %Y %I:%M %p')
  parag = soup.find("div", {"class": "article rte-article"})
  para = parag.find_all('p')
  place = para[0].get_text().split(':')[0]
  article = Article(urls)
  article.download()
  article.parse()
  article.nlp()
  summary = article.summary
  data[count] = [date_time, place, summary, article.keywords]
  count += 1

df = pd.DataFrame.from_dict(data, orient='index',
                            columns=['Date', 'Place', 'Context', 'Keywords'])
for row in df.values:
  if '(' in row[1]:
    row[1] = row[1].split('(')[0]
    print(row[1])
  if '/' in row[1]:
    row[1] = row[1].split('/')[0]
    print(row[1])
  if ',' in row[1]:
    row[1] = row[1].split(',')[0]
    print(row[1])
df = df.append(news)
for row in df.values:
  row[0] = pd.to_datetime(row[0])
df.sort_values(by='Date', inplace=True, ascending=False)
df.to_csv('news_feed.csv', header=True, index=False, date_format='%Y-%m-%d %H:%M:%S')
