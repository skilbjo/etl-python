from lib.format import format

def transform(data):
	return tuple(data)
	# ojb_to_array(data)

def tuple(data):
	return data

def ojb_to_array(data):
	result_data = []
	for row in data:
		result_row = []
		for key, value in row.items():
			result_row.append(value)
		result_data.append(result_row)