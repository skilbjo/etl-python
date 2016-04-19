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
		f_costs(sql)
	elif(db == 'finance_yapdm'):
		f_yapdm(sql)

def crostoli(sql, cb=''):
	import pymssql
	conn = pymssql.connect('crostoli.hq.rentpayment.com',config.get('crostoli','user'),config.get('crostoli','passwd'))
	cursor = conn.cursor(as_dict=True)

	data=[]
	sql='select 1+1 as Answer'

	cursor.execute(sql)
	for row in cursor:
		data.append(row)
	conn.close()
	transform(data)


def f_costs(sql):
	import psycopg2
	import psycopg2.extras
	conn = psycopg2.connect(host='finance', database='costs', user='skilbjo', password='ys')
	cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

	data=[]
	sql='select 1+1 as Answer'

	cursor.execute(sql)
	for row in cursor:
		data.append(dict(row))
	conn.close()	
	transform(data)

	print('fcosts')

def f_yapdm(sql):
	print('yapdm')

extract('f_costs','./sql/Dimension/Analytics/Analytics.sql')
# extract('crostoli','./sql/Dimension/Analytics/Analytics.sql')



