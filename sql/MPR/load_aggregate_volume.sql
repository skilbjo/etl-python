insert into aggregate_volume (
	Date, PlatformId, ParentAccountId, ParentName, DateFirstSeen,
	Gateway, FeePaymentType, IssuerType, PaymentTypeGroup,  
	TPV_USD, TPV_Net_USD
	) values (
		%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
)