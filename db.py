#Python to PostgreSQL
import psycopg2
from configparser import ConfigParser


def config(filename='connections/db.ini', section='postgresql'):
  parser = ConfigParser()
  parser.read(filename)
  db = {}
  if parser.has_section(section):
    params = parser.items(section)
    for param in params:
      db[param[0]] = param[1]
  else:
    raise Exception('Section {0} not found in the {1} file'.format(section, filename)
  )
  return db

try:
    params = config()
    connection = psycopg2.connect(**params)

    cursor = connection.cursor()
    print ( connection.get_dsn_parameters(), "\n")

    cursor.execute("SELECT * FROM scopes WHERE signid = 12;")
    record = cursor.fetchall()
    print("The sources are ", record, "\n So feel good!")

except (Exception, psycopg2.Error) as error :
    print ("Error while connecting to PostgreSQL", error)

def insert_scope()  