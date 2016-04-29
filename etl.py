#!/usr/bin/env python

import argparse
import sys
sys.path.append('./etl')

import extract
import transform
import load

def main(server, sql_extract , sql_load ):
	data = extract.extract(server, sql_extract )
	data = transform.transform(data)
	return load.load( data, sql_load )

if __name__ == '__main__':
	parser = argparse.ArgumentParser(description='ETL program.')
	parser.add_argument('-s','--server', help='Extract phase: server for where the data lives. Either "crostoli", "finance_costs", or "finance_yapstonedm"')	
	parser.add_argument('-e','--extract', help='Extract phase: SQL file path')
	parser.add_argument('-l','--load', help='Load phase: SQL file path')

	args = parser.parse_args()

	main( args.server , args.extract , args.load )


