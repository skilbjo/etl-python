with Date as (
	select (date_trunc('Month',current_date) - interval '1 day')::DATE as StartDate
),
Initial_COGS as (
	select
		MPR.Date,
		sum(
		case    when  MPR.PaymentTypeGroup in ('ACH_Scan','AmEx') then (Txn_Count * Costs.ACH) else 0 end +
		case    when  MPR.Vertical not in ('HA') and MPR.PaymentTypeGroup in ('Card','AmEx-Processing') then
									coalesce( ((Credit_Card_Net_USD - Amex_Processing_Net_USD) * Costs.Credit * 0.01),0) + coalesce((Debit_Card_Net_USD * Costs.Debit * 0.01),0) + coalesce((Amex_Processing_Net_USD * Costs.Amex * 0.01),0) + coalesce((case when TPV is null and PaymentTypeGroup in ('Card') then TPV_Billing else 0 end * Costs.Blend * 0.01),0)
						when  MPR.Vertical in ('HA') and MPR.PaymentTypeGroup in ('Card','AmEx-Processing') and FeePaymentType in ('PropertyPaid') then
										coalesce(Financials.Homeaway,0)
						else 0 end
		) Initial_COGS
	from
		mpr_base MPR
		left join Costs on Costs.Vertical = MPR.Vertical and MPR.Gateway in ('YapProcessing') and MPR.PaymentTypeGroup not in ('Cash')
		left join Financials_Base Financials on MPR.Date = Financials.Date and MPR.Gateway in ('YapProcessing') and MPR.PaymentTypeGroup in ('Card')
	where MPR.Gateway in ('YapProcessing') and MPR.Vertical not in ('HA-Intl') and MPR.PaymentTypeGroup not in ('Cash')
	group by
		MPR.Date
),
COGS_Financials as (
	select
		COGS_Financials_Base.*, (COGS_Financials_Base.Total_COGS - Initial_COGS.Initial_COGS) Allocation
	from
		Financials_Base COGS_Financials_Base
		join Initial_COGS on COGS_Financials_Base.Date = Initial_COGS.Date
),
MPR as (
	select
		MPR.Date, MPR.PlatformId,MPR.Gateway,MPR.Vertical, MPR.SoftwareName, MPR.ParentAccountId, MPR.ParentName , 
		MPR.FeePaymentType, MPR.PaymentTypeGroup ,
		sum(TPV_USD) TPV_USD,
		sum(TPV_Net_USD) TPV_Net_USD,
		sum(Revenue_Net_USD) Revenue_Net_USD ,
		sum(coalesce(
			case 	when MPR.PaymentTypeGroup in ('ACH_Scan','AmEx') then (Txn_Count * Costs.ACH) else 0 end +
			case 	when MPR.Vertical not in ('HA') and MPR.PaymentTypeGroup in ('Card','AmEx-Processing') then
								coalesce( ((Credit_Card_Net_USD - Amex_Processing_Net_USD) * Costs.Credit * 0.01),0) + coalesce((Debit_Card_Net_USD * Costs.Debit * 0.01),0) + coalesce((Amex_Processing_Net_USD * Costs.Amex * 0.01),0) + coalesce((case when TPV is null and PaymentTypeGroup in ('Card') then TPV_Billing else 0 end * Costs.Blend * 0.01),0)
								+(coalesce( ( ( cast(Card_Volume_Net_USD as decimal(18,2) ) / cast(COGS_Financials.Allocable_Card_Volume as decimal(18,2)) ) * COGS_Financials.Allocation  ), 0) ) -- Excess
						when MPR.Vertical in ('HA') and MPR.PaymentTypeGroup in ('Card','AmEx-Processing') and MPR.FeePaymentType in ('PropertyPaid') then	coalesce(COGS_Financials.Homeaway,0)
						else 0
			end,0)
		) COGS_USD,
		sum(Txn_Count) Txn_Count
	from
		mpr_base MPR
		left join Costs on Costs.Vertical = MPR.Vertical and MPR.Gateway in ('YapProcessing') and MPR.PaymentTypeGroup not in ('Cash')
		left join COGS_Financials on MPR.Date = COGS_Financials.Date and MPR.Gateway in ('YapProcessing') and MPR.PaymentTypeGroup in ('Card','AmEx-Processing')
	where
		MPR.Date in ( select StartDate from Date ) 
		and MPR.Vertical not in ('HA-Intl')
	group by
			MPR.Date, MPR.PlatformId, MPR.Gateway, MPR.Vertical , MPR.SoftwareName, MPR.ParentAccountId ,MPR.ParentName,
			MPR.FeePaymentType, MPR.PaymentTypeGroup
)
select
	Date, PlatformId, SoftwareName , Gateway, Vertical,ParentAccountId, ParentName , 
	FeePaymentType, PaymentTypeGroup ,
	sum(TPV_USD)::money as TPV_USD, (sum(TPV_USD) - sum(TPV_Net_USD))::money as "Refunds/Chargebacks", sum(TPV_Net_USD)::money as TPV_Net_USD ,
	sum(Txn_Count)::int as Txn_Count, 	
	sum(Revenue_Net_USD)::money as Revenue_Net_USD, sum(COGS_USD)::money as COGS_USD
from
	MPR
group by
	Date, PlatformId, SoftwareName , Gateway, Vertical, ParentAccountId, ParentName , 
	FeePaymentType, PaymentTypeGroup 