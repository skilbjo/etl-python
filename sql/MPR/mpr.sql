with Date as ( 
	select (date_trunc('Month',current_date) - interval '1 day')::DATE as StartDate
),
COGS as (
	select 'Dues' Vertical,	1.97 Credit,	0.35 Debit,	1.19 Blend ,	0.03 Amex,	0.03 ACH union
	select 'Inn' , 	1.95 ,	0.44 ,	1.65 ,	0.03 ,	0.03 union
	select 'Rent' , 	2.02 ,	0.38 ,	1.13 ,	0.03 ,	0.03 union
	select 'VRP' , 	1.87 ,	0.38 ,	1.5 ,	0.03 ,	0.03 union
	select 'SRP' , 	2.1 ,	0.73 ,	1.18 ,	0.03 ,	0.03 union
	select 'HA' , 	1.9 ,	0.37 ,	1.64 ,	0.03 ,	0.03 union
	select 'NonProfit' , 	2.48 ,	1.02 ,	2.26 ,	0.03 ,	0.03 union
	select  'HA-Intl', 	1.9 ,	0.4 ,	1.43 ,	null ,	null
), 
Allocable_Card_Volume as (
	select MPR.Date, sum(MPR.Card_Volume_Net_USD)  Allocable_Card_Volume
	from  mpr_base MPR  
	where MPR.Gateway in ('YapProcessing') and MPR.Vertical not in ('HA-Intl','HA')
	group by MPR.Date
),
COGS_Financials_Base as (
	select '2013-01-31'::DATE Date , 4334559 Total_COGS , 765895 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2013-01-31') ) Allocable_Card_Volume union
	select '2013-02-28'::DATE Date , 3953897 Total_COGS , 731973 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2013-02-28') ) Allocable_Card_Volume union
	select '2013-03-31'::DATE Date , 3913363 Total_COGS , 721878 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2013-03-31') ) Allocable_Card_Volume union
	select '2013-04-30'::DATE Date , 3928581 Total_COGS , 777925 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2013-04-30') ) Allocable_Card_Volume union
	select '2013-05-31'::DATE Date , 5044537 Total_COGS , 1018972 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2013-05-31') ) Allocable_Card_Volume union
	select '2013-06-30'::DATE Date , 5522725 Total_COGS , 1110487 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2013-06-30') ) Allocable_Card_Volume union
	select '2013-07-31'::DATE Date , 5457970 Total_COGS , 1196230 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2013-07-31') ) Allocable_Card_Volume union
	select '2013-08-31'::DATE Date , 3965201 Total_COGS , 873302 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2013-08-31') ) Allocable_Card_Volume union
	select '2013-09-30'::DATE Date , 3460856 Total_COGS , 860966 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2013-09-30') ) Allocable_Card_Volume union
	select '2013-10-31'::DATE Date , 3764626 Total_COGS , 882692 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2013-10-31') ) Allocable_Card_Volume union
	select '2013-11-30'::DATE Date , 4055276 Total_COGS , 974769 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2013-11-30') ) Allocable_Card_Volume union
	select '2013-12-31'::DATE Date , 4195839 Total_COGS , 1137395 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2013-12-31') ) Allocable_Card_Volume union
	select '2014-01-31'::DATE Date , 6173394 Total_COGS , 1719081 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2014-01-31') ) Allocable_Card_Volume union
	select '2014-02-28'::DATE Date , 5255634 Total_COGS , 1596313 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2014-02-28') ) Allocable_Card_Volume union
	select '2014-03-31'::DATE Date , 5740891 Total_COGS , 1782774 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2014-03-31') ) Allocable_Card_Volume union
	select '2014-04-30'::DATE Date , 5309589 Total_COGS , 1689962 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2014-04-30') ) Allocable_Card_Volume union
	select '2014-05-31'::DATE Date , 6702025 Total_COGS , 2131137 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2014-05-31') ) Allocable_Card_Volume union
	select '2014-06-30'::DATE Date , 7670034 Total_COGS , 2476637 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2014-06-30') ) Allocable_Card_Volume union
	select '2014-07-31'::DATE Date , 6970573 Total_COGS , 2277938 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2014-07-31') ) Allocable_Card_Volume union
	select '2014-08-31'::DATE Date , 4975568 Total_COGS , 1698512 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2014-08-31') ) Allocable_Card_Volume union
	select '2014-09-30'::DATE Date , 5012709 Total_COGS , 1830178 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2014-09-30') ) Allocable_Card_Volume union
	select '2014-10-31'::DATE Date , 5223066 Total_COGS , 1775187 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2014-10-31') ) Allocable_Card_Volume union
	select '2014-11-30'::DATE Date , 5080146 Total_COGS , 1920112 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2014-11-30') ) Allocable_Card_Volume union
	select '2014-12-31'::DATE Date , 6342268 Total_COGS , 2369502 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2014-12-31') ) Allocable_Card_Volume union
	select '2015-01-31'::DATE Date , 8204391 Total_COGS , 3372823 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2015-01-31') ) Allocable_Card_Volume union
	select '2015-02-28'::DATE Date , 7263639 Total_COGS , 3017642 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2015-02-28') ) Allocable_Card_Volume union
	select '2015-03-31'::DATE Date , 8013648 Total_COGS , 3315023 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2015-03-31') ) Allocable_Card_Volume union
	select '2015-04-30'::DATE Date , 7342937 Total_COGS , 3000951 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2015-04-30') ) Allocable_Card_Volume union
	select '2015-05-31'::DATE Date , 8717660 Total_COGS , 3503107 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2015-05-31') ) Allocable_Card_Volume union
	select '2015-06-30'::DATE Date , 10721203 Total_COGS , 4363967 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2015-06-30') ) Allocable_Card_Volume union
	select '2015-07-31'::DATE Date , 9287115 Total_COGS , 3672875 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2015-07-31') ) Allocable_Card_Volume union
	select '2015-08-31'::DATE Date , 7186661 Total_COGS , 2889690 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2015-08-31') ) Allocable_Card_Volume union
	select '2015-09-30'::DATE Date , 6386660 Total_COGS , 2661722 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2015-09-30') ) Allocable_Card_Volume union
	select '2015-10-31'::DATE Date , 6560096 Total_COGS , 2731206 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2015-10-31') ) Allocable_Card_Volume union
	select '2015-11-30'::DATE Date , 7485626 Total_COGS , 3187536 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2015-11-30') ) Allocable_Card_Volume union
	select '2015-12-31'::DATE Date , 7849861 Total_COGS , 3301992 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2015-12-31') ) Allocable_Card_Volume union
	select '2016-01-31'::DATE Date , 10455477 Total_COGS , 4733567 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2016-01-31') ) Allocable_Card_Volume union
	select '2016-02-29'::DATE Date , 10059903 Total_COGS , 4741161 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2016-02-29') ) Allocable_Card_Volume union
	select '2016-03-31'::DATE Date , 9426188 Total_COGS , 3818629 Homeaway , (select Allocable_Card_Volume from Allocable_Card_Volume where Date in ('2016-03-31') ) Allocable_Card_Volume 
),
Initial_COGS as (
	select
		MPR.Date,
		sum(
		case 	when 	MPR.PaymentTypeGroup in ('ACH_Scan','AmEx') then (Txn_Count * COGS.ACH) else 0 end +
		case 	when 	MPR.Vertical not in ('HA') and MPR.PaymentTypeGroup in ('Card','AmEx-Processing') then
								coalesce( ((Credit_Card_Net_USD - Amex_Processing_Net_USD) * COGS.Credit * 0.01),0) + coalesce((Debit_Card_Net_USD * COGS.Debit * 0.01),0) + coalesce((Amex_Processing_Net_USD * COGS.Amex * 0.01),0) + coalesce((case when TPV is null and PaymentTypeGroup in ('Card') then TPV_Billing else 0 end * COGS.Blend * 0.01),0)
					when 	MPR.Vertical in ('HA') and MPR.PaymentTypeGroup in ('Card','AmEx-Processing') and FeePaymentType in ('PropertyPaid') then
								coalesce(COGS_Financials.Homeaway,0)
								else 0 end
		) Initial_COGS
	from
		mpr_base MPR
		left join COGS on COGS.Vertical = MPR.Vertical and MPR.Gateway in ('YapProcessing') and MPR.PaymentTypeGroup not in ('Cash')
		left join COGS_Financials_Base COGS_Financials on MPR.Date = COGS_Financials.Date and MPR.Gateway in ('YapProcessing') and MPR.PaymentTypeGroup in ('Card')
	where MPR.Gateway in ('YapProcessing') and MPR.Vertical not in ('HA-Intl') and MPR.PaymentTypeGroup not in ('Cash')
	group by
		MPR.Date
),
COGS_Financials as (
	select
		COGS_Financials_Base.*, (COGS_Financials_Base.Total_COGS - Initial_COGS.Initial_COGS) Allocation
	from
		COGS_Financials_Base
		join Initial_COGS on COGS_Financials_Base.Date = Initial_COGS.Date
),
MPR_temp as (
	select
		MPR.Date, MPR.PlatformId,MPR.Gateway,MPR.Vertical, MPR.SoftwareName, MPR.ParentAccountId, MPR.ParentName , 
		MPR.FeePaymentType, MPR.PaymentTypeGroup ,
		sum(TPV_USD) TPV_USD,
		sum(TPV_Net_USD) TPV_Net_USD,
		sum(Revenue_Net_USD) Revenue_Net_USD ,
		sum(coalesce(
			case 	when MPR.PaymentTypeGroup in ('ACH_Scan','AmEx') then (Txn_Count * COGS.ACH) else 0 end +
			case 	when MPR.Vertical not in ('HA') and MPR.PaymentTypeGroup in ('Card','AmEx-Processing') then
					coalesce( ((Credit_Card_Net_USD - Amex_Processing_Net_USD) * COGS.Credit * 0.01),0) + coalesce((Debit_Card_Net_USD * COGS.Debit * 0.01),0) + coalesce((Amex_Processing_Net_USD * COGS.Amex * 0.01),0) + coalesce((case when TPV is null and PaymentTypeGroup in ('Card') then TPV_Billing else 0 end * COGS.Blend * 0.01),0)
				+(coalesce( ( ( cast(Card_Volume_Net_USD as decimal(18,2) ) / cast(COGS_Financials.Allocable_Card_Volume as decimal(18,2)) ) * COGS_Financials.Allocation  ), 0) ) -- Excess
						when MPR.Vertical in ('HA') and MPR.PaymentTypeGroup in ('Card','AmEx-Processing') and MPR.FeePaymentType in ('PropertyPaid') then	coalesce(COGS_Financials.Homeaway,0)
						else 0
		  end,0)
		) COGS_USD,
		sum(Txn_Count) Txn_Count
	from
		mpr_base MPR
		left join COGS on COGS.Vertical = MPR.Vertical and MPR.Gateway in ('YapProcessing') and MPR.PaymentTypeGroup not in ('Cash')
		left join COGS_Financials on MPR.Date = COGS_Financials.Date and MPR.Gateway in ('YapProcessing') and MPR.PaymentTypeGroup in ('Card','AmEx-Processing')
	where
		MPR.Date in ( select StartDate from Date ) 
		and MPR.Vertical not in ('HA-Intl')
	group by
	    MPR.Date, MPR.PlatformId, MPR.Gateway, MPR.Vertical , MPR.SoftwareName, MPR.ParentAccountId ,MPR.ParentName,
	    MPR.FeePaymentType, MPR.PaymentTypeGroup
)
-- insert into MPR
select
	Date, PlatformId, Gateway, Vertical, SoftwareName , ParentAccountId, ParentName , 
	FeePaymentType, PaymentTypeGroup ,
	sum(TPV_USD)::money as TPV_USD, (sum(TPV_USD) - sum(TPV_Net_USD))::money as Refunds_Chargebacks, sum(TPV_Net_USD)::money as TPV_Net_USD ,
	sum(Txn_Count)::int as Txn_Count, 	
	sum(Revenue_Net_USD)::money as Revenue_Net_USD, sum(COGS_USD)::money as COGS_USD
from
	MPR_temp
group by
	Date, PlatformId, Gateway, Vertical, SoftwareName ,  ParentAccountId, ParentName , 
	FeePaymentType, PaymentTypeGroup 


