import configparser

config = configparser.ConfigParser()
config.read('config')

user = config.get('crostoli','user')

print(user)

# import json

# file = './crostoli.json'

# with open(file,'r') as f:
# 	for (k,v) in f:
# 		print(k)

# for (n, v) in 

# print(file)

# def foo(x):
# 	print(x)

# def bar(x):
# 	print(x)

# def switch(arg):
# 	return {
# 		'a': foo(arg),
# 		'blah': bar(arg)
# 	}[arg]

# switch('a')