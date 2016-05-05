#!/usr/bin/env python

import argparse
import sys
sys.path.append('./etl')

import petl
import extract
import transform
import load

def main(server, csv_file , sql_load ):
	# data = extract.extract(server, sql_extract )
	data = petl.convert(csv_file, 'blah', 'upper')
	data = transform.transform(data)
	return load.load( data, sql_load )

if __name__ == '__main__':
	parser = argparse.ArgumentParser(description='ETL program.')
	parser.add_argument('-s','--server', help='Extract phase: server for where the data lives. Either "crostoli", "finance_costs", or "finance_yapstonedm"', required=True)	
	parser.add_argument('-f','--file', help='Extract phase: csv file path', required=True)
	parser.add_argument('-l','--load', help='Load phase: SQL file path', required=True)

	args = parser.parse_args()

	main( args.server , args.extract , args.load )


