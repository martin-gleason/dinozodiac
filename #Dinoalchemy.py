#Dinoalchemy

import sqlalchemy
import pandas as pd
from sqlalchemy import create_engine, MetaData, Table
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, Date
from sqlalchemy import inspect
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import select
from sqlalchemy.ext.automap import automap_base



db_url = ('postgresql+psycopg2://marty:bricu1916@localhost:5432/dinozodiac')
engine = create_engine(db_url)

def get_tables(engine, targetTable):
  Base = Base = declarative_base()
  Base.metadata.create_all(engine)
  tableMetaData = MetaData(engine)
  dataTable = Table(targetTable, tableMetaData, autoload = True)
  return dataTable

test = get_tables(engine, 'signs')
print(test)

test2 = get_tables(engine, 'scopes')


test_df = pd.DataFrame()
test_df["sign_id"] = [13]
test_df['greekname'] = ['Diana']
test_df['dinoname'] = ['utahraptor']
test_df.columns = [['sign_id', 'greekname', 'dinoname']]


#test_df.set_index('sign_id', inplace = True, drop = True, append = True)



DBSession = sessionmaker(bind = engine)
session = DBSession()

results = select([test])

scope_results = select([test2])
print(type(scope_results))
signs_df = pd.read_sql(results, engine)

scopes_results_query=pd.read_sql(scope_results, engine)

print(signs_df)
print(scopes_results_query)

#test_df.to_sql(test, con = engine, if_exists = 'append', index = False, dtype={"sign_id": Integer()})
# signs_df.to_sql(test_df, engine, if_exists = 'append', dtype={"sign_id": Integer()})
# session.commit()


print(signs_df)
