import requests
import os
from datetime import datetime
from bs4 import BeautifulSoup

today = datetime.now()

today = today.strftime('%m_%d_%Y')

url = 'https://horoscope.com/us/horoscopes/general/horoscope-general-daily-today.aspx?sign='

page = requests.get(url)

soup = BeautifulSoup(page.content, 'html.parser')

scopes = soup.findAll('a', href = True)

#note: hscopes does it at the end of the string +1, so, sig


def getScopeText(url):
  page = requests.get(url)
  soup = BeautifulSoup(page.content, 'html.parser')
  scope = soup.find('p')
  return scope

def getHeader(url):
  page = requests.get(url)
  soup = BeautifulSoup(page.content, 'html.parser')
  header = soup.find('h1')
  return header

links = []

l = 13

for i in range(1, l):
  links.append(url+str(i))


astrologyComScopes = []


for i in range(len(links)):
  astrologyComScopes.append(str(i+1) + ":")
  astrologyComScopes.append(getHeader(links[i]))
  astrologyComScopes.append(links[i])
  astrologyComScopes.append('\n')
  astrologyComScopes.append(getScopeText(links[i]))
  astrologyComScopes.append('\n')



#save to text file


dir = '/Users/marty/Local Dev Projects/dinozodiac/astrohistory'
fileName = 'hororscopecom_' + today + '.txt'
os.chdir(dir)


with open(fileName, 'w') as filehandle:
  filehandle.writelines("%s\n" % line for line in astrologyComScopes)