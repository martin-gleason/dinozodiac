import requests
import os
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


astrologyComScopes = []

l = len(links)

for i in range(l):
  astrologyComScopes.append(str(i) + ":")
  astrologyComScopes.append(links[i])
  astrologyComScopes.append(getScopeText(links[i]))
  astrologyComScopes.append('\n')




dir = '/Users/marty/Local Dev Projects/dinozodiac/astrologyComCSV'
fileName = 'astrologyCom_' + today + '.txt'
os.chdir(dir)

with open(fileName, 'w') as filehandle:
  filehandle.writelines("%s\n" % line for line in astrologyComScopes)