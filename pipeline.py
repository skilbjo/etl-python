#!/usr/bin/env python

import argparse
import sys
import petl as etl
import csv

vantivfile = './csv/vantiv/2016-04-30'
headers = [ 'Chain', 'Merchant_Id', 'Txn_Date', 'MCC', 'Network', 'Code', 'Qualification_Code', 'Txn_Amount', 'Interchange', 'Surcharge', 'Txn_Id' ]

def main(server, csv_file , sql_load ):
	data = petl.convert(csv_file, 'blah', 'upper')

if __name__ == '__main__':
	parser = argparse.ArgumentParser(description='ETL program.')	
	parser.add_argument('-f','--file', help='Extract phase: csv file path') #, required=True)
	parser.add_argument('-l','--load', help='Load phase: SQL file path') #, required=True)

	args = parser.parse_args()

	main( args.server , vantivfile , args.load )


'''
create table vantiv (
	Chain varchar,
	Merchant_Id varchar,
	Txn_Date date,
	MCC int,
	Network varchar,
	Code varchar,
	Qualification_Code varchar,
	Txn_Amount decimal(48,2),
	Interchange decimal(48,2),
	Surcharge decimal(48,2),
	Txn_Id varchar
)
'''


# sys.path.append('./etl')
# import extract
# import transform
# import load