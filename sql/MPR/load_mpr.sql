insert into mpr(
	Date, PlatformId, SoftwareName, Gateway, Vertical,
	ParentAccountId, ParentName, FeePaymentType, PaymentTypeGroup, 
	TPV_USD , Refunds_Chargebacks, TPV_Net_USD, Txn_Count, Revenue, COGS_USD
	) values (
		%s,%s,%s,%s,%s%s,%s,%s,%s,%s%s,%s,%s,%s,%s
	)