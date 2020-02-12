import requests
from bs4 import BeautifulSoup

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


""" ariesPage = requests.get(links[0])
ariesSoup = BeautifulSoup(ariesPage.content, 'html.parser')
ariesScope = ariesSoup.find('p')

for p in links:
  scopePages.append(requests.get(links[p]))
  print(scopePages[p])
  #scopePages.append(BeautifulSoup(scopePages[p], 'html.parser'))

 """




astrologyComScopes = []

l = len(links)

print(l)

for i in range(l):
  astrologyComScopes.append(getScopeText(links[i]))

print(astrologyComScopes)