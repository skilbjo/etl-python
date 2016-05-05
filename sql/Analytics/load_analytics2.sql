insert into analytics_test (
	Year,
	Month,
	Date,
	PlatformId,
	Gateway, 
	Vertical,
	PaymentType,
	Network,
	PaymentTypeGroup,
	Currency,
	TPV,
	TPV_USD,
	Txn_Count,
	Card_Volume,
	Card_Txn_Count,
	Card_Volume_USD
) values (
	%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s
)