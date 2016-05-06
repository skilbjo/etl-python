-- TopData
declare @now as date, @start as date, @end as date 

set @now = getdate()
set @start = dateadd(mm,(year(@now)- 1900) * 12 + month(@now) - 1 -1 , 0) 
set @end = dateadd(d,-1 , dateadd(mm,(year(@now)- 1900) * 12 + month(@now)- 1 , 0))  --'2014-12-31'--dateadd(d,-1 , dateadd(mm,(year(@now)- 1900) * 12 + month(@now)- 1 , 0))   
-- set @start = '2012-01-01'--'2015-01-01'--dateadd(mm,(year(@now)- 1900) * 12 + month(@now) - 1 -1 , 0) 
-- set @end = '2014-12-31'--dateadd(d,-1 , dateadd(mm,(year(@now)- 1900) * 12 + month(@now)- 1 , 0))  --'2014-12-31'--dateadd(d,-1 , dateadd(mm,(year(@now)- 1900) * 12 + month(@now)- 1 , 0))   

if object_id('tempdb..#Billing') is not null drop table #Billing
select * into #Billing from (
select Year, Month, Date, PlatformId, Vertical, SoftwareName, ParentAccountId, ParentName,
 	--case when PaymentType in ('Visa','MasterCard','Discover','Debit','International Surcharge') then 'Card' when PaymentType in ('eCheck','e-Check','Scan','Scanned Checks') then 'ACH_Scan' when PaymentType in ('American Express','AmericanExpress','Amex') then  case when Txn_Amount >= 200 and (Revenue / Txn_Amount)*100 > 1.5 then 'Amex-Processing' else 'Amex' end end as Payment_Type,
	sum(Txn_Amount) Txn_Amount, sum(Revenue) Revenue, sum(Txn_Count) Txn_Count 
	from (
		select billing.Year, billing.Month , cast(dateadd(d, -1 , dateadd(mm, (Billing.Year - 1900) * 12 + Billing.Month, 0)) as date) as Date, billing.PlatformId 
		, c.Vertical , c.SoftwareName , c.ParentAccountId, c.ParentName , billing.PaymentType  ,
		sum(case when billing.PaymentType not in ('International Surcharge') then billing.Volume else 0 end) Txn_Amount,
		sum(billing.Charge) Revenue,
		sum(case when billing.PaymentType not in ('International Surcharge') then 1 else 0 end) Txn_Count
		from
			ETLStaging.dbo.PropertyPaidBilling billing
			inner join ETLStaging.dbo.FinanceParentTable c on billing.PlatformID = c.PlatformId and billing.ChildAccountID = c.ChildAccountId
		group by billing.Year, billing.Month, cast(dateadd(d, -1 , dateadd(mm, (Billing.Year - 1900) * 12 + Billing.Month, 0)) as date), billing.PlatformId,
			c.Vertical, c.SoftwareName,c.ParentAccountId , c.ParentName , billing.PaymentType
	) src
group by Year, Month, Date, PlatformId, Vertical, SoftwareName, ParentAccountId, ParentName
 	--,case when PaymentType in ('Visa','MasterCard','Discover','Debit','International Surcharge') then 'Card' when PaymentType in ('eCheck','e-Check','Scan','Scanned Checks') then 'ACH_Scan' when PaymentType in ('American Express','AmericanExpress','Amex') then  case when Txn_Amount >= 200 and (Revenue / Txn_Amount)*100 > 1.5 then 'Amex-Processing' else 'Amex' end end
) src
where Date between @start and @end

if object_id('tempdb..#Txn') is not null drop table #Txn
select year(txn.postdate_r) Year , month(txn.postdate_r) Month , cast(dateadd(d,  0, dateadd(d, -1 , dateadd(mm, (year(txn.PostDate_r) - 1900) * 12 + month(txn.PostDate_r) , 0))) as date) as Date , txn.PlatformId PlatformId, case when txn.processorid in (14) then 'GatewayOnly' else 'YapProcessing' end as Gateway ,
	c.Vertical, c.SoftwareName , c.ParentAccountId , c.ParentName, cur.CharCode Currency ,
	sum( txn.Amount ) TPV, sum( txn.Amount * fx.Rate ) TPV_USD ,
	sum( isnull(txn.AmtNetConvFee,0) + isnull(txn.AmtNetPropFee,0) ) Revenue, sum( isnull(txn.AmtNetConvFee,0) + isnull(txn.AmtNetPropFee,0) * fx.Rate ) Revenue_USD    ,  
	--count(*) as Txn_Count,
	count(distinct(case when txn.TransactionCycleId in (1) then cast(left(txn.IdClassId, charindex(':', txn.IdClassId) -1 ) as varchar) + cast(txn.TransactionCycleId as varchar) else null end )) Txn_Count,      
	sum(case when txn.paymenttypeid in (1, 2, 3, 11, 12, /* <-- regular cards */ /* pre 2012 debit networks --> */  6,7,8,9) and txn.TransactionCycleId in (1) then txn.Amount when txn.PaymentTypeId in (10) and txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) /* Amex , Bucket , Vantiv = Processing */ and txn.TransactionCycleId in (1) then txn.Amount else 0 end) as Card_Volume,
	sum(case when txn.paymenttypeid in (1, 2, 3, 11, 12, /* <-- regular cards */ /* pre 2012 debit networks --> */  6,7,8,9) and txn.TransactionCycleId in (1) then txn.Amount  when txn.PaymentTypeId in (10) and txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) /* Amex , Bucket , Vantiv = Processing */ and txn.TransactionCycleId in (1) then txn.Amount else 0 end * fx.Rate ) as Card_Volume_USD
	into #txn
from
	YapstoneDM.dbo.[Transaction] txn
	inner join YapstoneDM.dbo.Currency cur on txn.CurrencyId = cur.CurrencyId
	inner join ETLStaging.dbo.FinanceParentTable c on txn.PlatformId = c.PlatformId and txn.Ref_CompanyId = c.ChildCompanyId
	inner join ETLStaging..FinanceFXRates fx on  txn.PostDate_R = fx.Date and txn.CurrencyId = fx.CurrencyId   
where
		txn.ProcessorId not in (16)
		and txn.TransactionCycleId in (1)
		and txn.PostDate_R between  @start and @end
group by year(txn.postdate_r) , month(txn.postdate_r) , cast(dateadd(d,  0, dateadd(d, -1 , dateadd(mm, (year(txn.PostDate_r) - 1900) * 12 + month(txn.PostDate_r) , 0))) as date),txn.PlatformId  ,case when txn.processorid in (14) then 'GatewayOnly' else 'YapProcessing' end ,
	c.Vertical, c.SoftwareName , c.ParentAccountId , c.ParentName, cur.CharCode
	 
if object_id('tempdb..#TopData') is not null drop table #TopData
select isnull(txn.Year,billing.Year) Year, isnull(txn.Month,billing.Month) Month,
	cast(isnull(txn.Date, billing.Date) as varchar) Date, isnull(txn.PlatformId,billing.PlatformId) PlatformId , isnull(txn.Gateway,'YapProcessing') Gateway, 
	isnull(txn.Vertical,billing.Vertical) Vertical, coalesce(txn.SoftwareName,billing.SoftwareName,'Non-Affiliated') SoftwareName ,isnull(txn.ParentAccountId,billing.ParentAccountId) ParentAccountId ,isnull(txn.ParentName,billing.ParentName) ParentName ,
	isnull(txn.Currency,'USD') Currency,
	sum( isnull(txn.TPV_USD,0) ) TPV_USD,
	sum( isnull(txn.Card_Volume_USD,0) ) Card_Volume_USD   ,
	sum( isnull(txn.Txn_Count,0) ) Txn_Count  ,
	sum( isnull(txn.Revenue_USD,0) + isnull(billing.Revenue,0) ) Revenue_USD 
	into #TopData
from
	#txn txn
	full outer  join #Billing billing	on	billing.Year = txn.Year and billing.Month = txn.Month and  billing.PlatformId = txn.PlatformId and billing.ParentAccountId = txn.ParentAccountId 
		and txn.Currency in ('USD') 
group by  isnull(txn.Year,billing.Year) , isnull(txn.Month,billing.Month) ,
	cast(isnull(txn.Date, billing.Date ) as varchar) , isnull(txn.PlatformId,billing.PlatformId)  , isnull(txn.Gateway,'YapProcessing') , 
	isnull(txn.Vertical,billing.Vertical) , coalesce(txn.SoftwareName,billing.SoftwareName,'Non-Affiliated')  ,isnull(txn.ParentAccountId,billing.ParentAccountId)  ,isnull(txn.ParentName,billing.ParentName)  ,
	isnull(txn.Currency,'USD') 
	
select * from #TopData
			
-- select 
-- 	PlatformId, 
-- 	convert(varchar,cast(sum(TPV_USD) as money),1) TPV_USD , 
-- 	convert(varchar,cast(sum(Card_Volume_USD) as money),1) Card_Volume_USD ,	
-- 	convert(varchar,cast(sum(Revenue_USD) as money),1) Revenue_USD,
-- 	convert(varchar,cast(sum(Txn_Count) as money),1) Txn_Count
-- from 
-- 	#TopData
-- where
-- 	Gateway in ('YapProcessing')
-- group by
-- 	Platformid      
-- order by
-- 	PlatformId
	
	