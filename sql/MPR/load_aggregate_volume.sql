insert into aggregate_volume (
	Date, PlatformId, ParentAccountId, ParentName,
	Gateway, FeePaymentType, PaymentTypeGroup, IssuerType, 
	TPV_USD, TPV_Net_USD
	) values (
		%s, %s, %s, %s, %s, %s, %s, %s, %s
)