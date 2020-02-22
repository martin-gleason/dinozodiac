import hororscope_pandas as h
import scrapeAstrologyCom_pandas as a
import pandas as pd
import sqlalchemy 
from sqlalchemy import create_engine
from sqlalchemy import engine_from_config
import db as db
import psycopg2
from configparser import ConfigParser
from psycopg2 import sql

config = db.config()

con = {
  'dbhost': config['host'],
  'db': config['database'],
  'username': config['user'],
  'pw': config['password'],
}

eng = engine_from_config(sql_alchemy_string, pool_size = 10)

eng = create_engine(sql_alchemy_string, pool_size = 10)
todays_scopes = pd.concat([h.horoscopecom, a.astrologyCom], ignore_index=True)


todays_scopes.to_sql('staging', eng)