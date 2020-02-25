import hororscope_pandas as h
import scrapeAstrologyCom_pandas as a
import Dinoalchemy as dino
import pandas as pd
import sqlalchemy 
from sqlalchemy import create_engine
from sqlalchemy import engine_from_config
import db as db
import psycopg2
from configparser import ConfigParser
from psycopg2 import sql

config = db.config()

engine = dino.connect_engine(config)

#testScope.to_sql('testing', engine, if_exists='append', index_label='id')

text = h.pdScopes['scope']

print(text)

todays_scopes = pd.concat([h.horoscopecom, a.astrologyCom], ignore_index=True)

print(todays_scopes)
print(todays_scopes['scope'].dtypes)

todays_scopes.to_sql('staging', engine, if_exists='append', index_label='staging_id')