import requests
import os
import pandas as pd
from datetime import datetime
from bs4 import BeautifulSoup

today = datetime.now()

today = today.strftime('%m_%d_%Y')


url = 'https://www.astrology.com/horoscope/daily/'

testUrl = 'https://www.astrology.com'

page = requests.get(url)

soup = BeautifulSoup(page.content, 'html.parser')

#get the signs 
#refactor into a function
signs = soup.findAll('div', {'class': 'signs'})
values = [item.get('value') for item in signs]
textSigns = [item.text for item in signs]

#get the horroscopes
scopes = soup.find(name = 'main')
scopeHrefs = scopes.findAll('a')

links = []

def getScopeText(url):
  page = requests.get(url)
  soup = BeautifulSoup(page.content, 'html.parser')
  scope = soup.find('p')
  return scope

for l in scopeHrefs:
  links.append(testUrl + l.attrs['href'])


astrologyComRange = []
astrologyComScopes = []




l = len(links)

for i in range(l):
  astrologyComRange.append(links[i])


for i in range(l):
  astrologyComScopes.append(getScopeText(links[i]))

astrologyCom = pd.DataFrame(
    {'link': astrologyComRange,
     'scope': astrologyComScopes
    })
