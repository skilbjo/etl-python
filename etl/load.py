import configparser
config = configparser.ConfigParser()
config.read('./lib/config/config')

def load(data , sql_file ):
	sql = read(sql_file)
	return finance_dm(data, sql)

def read(sql_load):
	sql=''
	with open(sql_load,'r') as f:
		for line in f:
			sql+=line
	return sql

def finance_dm(data, sql_load):
	import psycopg2
	import psycopg2.extras
	conn = psycopg2.connect(	
		host 			= config.get('finance_dm','server'), 
		database	= config.get('finance_dm','database'), 
		user			=	config.get('finance_dm','user'), 
		password	= config.get('finance_dm','passwd')
	)
	conn.autocommit = True

	cursor = conn.cursor()
	print(data)
	print(sql_load)
	cursor.executemany(sql_load, data)
	conn.close()

	return 'Data inserted'
