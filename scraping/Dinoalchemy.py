#Dinoalchemy
#pythonic means keeping imports at top

import sqlalchemy
import pandas as pd
import db as db
from sqlalchemy import create_engine, MetaData, Table
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, Date
from sqlalchemy import inspect
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import select
from sqlalchemy.ext.automap import automap_base

def connect_engine(config_file):
  user = config_file['user']
  host = config_file['host']
  pw = config_file['password']
  port = config_file['port']
  db = config_file['database']
  url = 'postgresql+psycopg2://{}:{}@{}:{}/{}'
  url = url.format(user, pw, host, port, db)
  engine = create_engine(url)

  return engine


#this seems to work. 
def get_tables(engine, targetTable):
  Base = Base = declarative_base()
  Base.metadata.create_all(engine)
  tableMetaData = MetaData(engine)
  dataTable = Table(targetTable, tableMetaData, autoload = True)
  return dataTable