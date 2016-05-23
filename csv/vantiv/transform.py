import petl as etl

import psycopg2
config = configparser.ConfigParser()
config.read('./../../lib/config/config')

conn = psycopg2.connect(	
	host 			= config.get('finance_dm','server'), 
	database	= config.get('finance_dm','database'), 
	user			=	config.get('finance_dm','user'), 
	password	= config.get('finance_dm','passwd')
)
conn.autocommit = True

table = etl.fromcsv('./../vantiv/files/2016-04-30')
headers = [ 'chain', 'merchant_id', 'txn_date', 'mcc', 'network', 'code', 'qualification_code', 'txn_amount', 'interchange', 'surcharge', 'txn_id' ]
table = etl.pushheader(table, headers)
table = etl.convertnumbers(table)
table = etl.convert(table, ['network','qualification_code'] , lambda field: field.strip() )

etl.progress.appenddb(table, conn, 'vantiv')

conn.close()