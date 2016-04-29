import configparser
config = configparser.ConfigParser()
config.read('./lib/config/config')

def extract(server, sql_file):
	sql = read(sql_file)
	return execute(server, sql)

def read(sql_load):
	sql=''
	with open(sql_load,'r') as f:
		for line in f:
			sql+=line
	return sql

def execute(server, sql):
	if(server == 'crostoli'):
		return crostoli(sql)
	elif(server == 'finance_costs'):
		return finance_costs(sql)
	elif(server == 'finance_dm'):
		return finance_dm(sql)

def crostoli(sql, cb=''):
	import pymssql
	conn = pymssql.connect(
		config.get('crostoli','server'), 
		config.get('crostoli','user'), 
		config.get('crostoli','passwd')
	)
	data=[]

	cursor = conn.cursor()
	cursor.execute(sql)
	for row in cursor:
		data.append(row)
	conn.close()

	return data

def finance_dm(sql):
	import psycopg2
	import psycopg2.extras
	conn = psycopg2.connect(	
		host 			= config.get('finance_dm','server'), 
		database	= config.get('finance_dm','database'), 
		user			=	config.get('finance_dm','user'), 
		password	= config.get('finance_dm','passwd')
	)
	data=[]

	cursor = conn.cursor()
	cursor.execute(sql)
	for row in cursor:
		data.append(row)
	conn.close()

	return data


def finance_costs(sql):
	import psycopg2
	import psycopg2.extras
	conn = psycopg2.connect(	
		host 			= config.get('finance_costs','server'), 
		database	= config.get('finance_costs','database'), 
		user			=	config.get('finance_costs','user'), 
		password	= config.get('finance_costs','passwd')
	)
	data=[]

	cursor = conn.cursor()
	cursor.execute(sql)
	for row in cursor:
		data.append(row)
	conn.close()

	return data



