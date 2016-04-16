import configparser
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
	elif(db == 'f_costs'):
		f_costs(sql)
	elif(db == 'f_yapdm'):
		f_yapdm(sql)

def crostoli(sql, cb=''):
	import pymssql
	data=[]
	#server = getenv('blah'), user = getenv('user'), passwd = getenv('passwd')
	sql='select 1+1 as Answer'
	conn = pymssql.connect('crostoli.hq.rentpayment.com',config.get('crostoli','user'),config.get('crostoli','passwd'))
	cursor = conn.cursor(as_dict=True)
	cursor.execute(sql)
	for row in cursor:
		data.append(row)
	conn.close()
	transform(data)

def transform(data):
	print(data)


def f_costs(sql):
	print('fcosts')

def f_yapdm(sql):
	print('yapdm')


extract('crostoli','./sql/Dimension/Analytics/Analytics.sql')



