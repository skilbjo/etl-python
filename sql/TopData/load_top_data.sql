insert into top_data (
	Year, 
	Month, 
	Date, 
	PlatformId, 
	Gateway, 
	Vertical,
	SoftwareName, 
	ParentAccountId, 
	ParentName, 
	Currency,
	TPV_USD, 
	Card_Volume_USD, 
	Txn_Count, 
	Revenue_USD
	) values (
		%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s
)

	