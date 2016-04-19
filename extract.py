import configparser
from transform import transform
config = configparser.ConfigParser()
config.read('./lib/config/config')

def extract(db, path):
	read(db, path)

def read(db, path):
	sql=''
	with open(path,'r') as f:
		for line in f:
			sql+=line
	execute(db,sql)

def execute(db, sql):
	if(db == 'crostoli'):
		crostoli(sql)
	elif(db == 'finance_costs'):
		finance_costs(sql)
	elif(db == 'finance_yapstonedm'):
		finance_yapdm(sql)

def crostoli(sql, cb=''):
	import pymssql
	conn = pymssql.connect('crostoli.hq.rentpayment.com',config.get('crostoli','user'), config.get('crostoli','passwd'))
	cursor = conn.cursor(as_dict=True)

	data=[]
	sql='select 1+1 as Answer'

	cursor.execute(sql)
	for row in cursor:
		data.append(row)
	conn.close()
	transform(data)


def finance_costs(sql):
	import psycopg2
	import psycopg2.extras
	conn = psycopg2.connect(host='finance', database='costs', user=config.get('finance_costs','user'), password=config.get('crostoli','passwd'))
	cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

	data=[]
	sql='select 1+1 as Answer'

	cursor.execute(sql)
	for row in cursor:
		data.append(dict(row))
	conn.close()	
	transform(data)


def finance_yapdm(sql):
	import psycopg2
	import psycopg2.extras
	conn = psycopg2.connect(host='finance', database='yapstonedm', user=config.get('finance_costs','user'), password=config.get('crostoli','passwd'))
	cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

	data=[]
	sql='select 1+1 as Answer'

	cursor.execute(sql)
	for row in cursor:
		data.append(dict(row))
	conn.close()	
	transform(data)

# extract('finance_costs','./sql/Dimension/Analytics/Analytics.sql')
# extract('crostoli','./sql/Dimension/Analytics/Analytics.sql')
# extract('finance_yapstonedm','./sql/Dimension/Analytics/Analytics.sql')


