insert into mpr_test (
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
	$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16
)