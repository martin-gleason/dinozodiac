import requests
import os
import pandas as pd
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


horoscopecomLinks = []
horoscopecomScope = []

for i in range(len(links)):
  horoscopecomLinks.append(links[i])

for i in range(len(links)):
  horoscopecomScope.append(getScopeText(links[i]))
 



horoscopecom = pd.DataFrame(
    {'link': horoscopecomLinks,
     'scope': horoscopecomScope
    }) 