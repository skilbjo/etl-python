insert into top_data (
	Year, Month, Date, PlatformId, Gateway, Vertical,
	SoftwareName, ParentAccountId, ParentName, Currency,
	TPV_USD, Card_Volume_USD, Txn_Count, Revenue_USD
	) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)