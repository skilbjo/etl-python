----Merchant Profitability Report
declare @now as date, @start as date, @end as date 

set @now = getdate()
set @start = dateadd(mm,(year(@now)- 1900) * 12 + month(@now) - 1 -1 , 0) 
set @end = dateadd(d,-1 , dateadd(mm,(year(@now)- 1900) * 12 + month(@now)- 1 , 0))  

if object_id('tempdb..#Cycle') is not null drop table #Cycle
select * into #Cycle from (
	select 1 TransactionCycleId,	'Gross' Type union
	select 3,	'Net' union
	select 4,	'Net' union
	select 9,	'Net' union
	select 16,	'Net' 
) src

if object_id('tempdb..#Billing') is not null drop table #Billing
select * into #Billing from (
select Year, Month, Date, PlatformId, Vertical, SoftwareName, ParentAccountId, ParentName,
 	case when PaymentType in ('Visa','MasterCard','Discover','Debit','International Surcharge') then 'Card' when PaymentType in ('eCheck','e-Check','Scan','Scanned Checks') then 'ACH_Scan' when PaymentType in ('American Express','AmericanExpress','AmEx') then 
			case when Txn_Amount >= 200 and (Revenue / Txn_Amount)*100 > 1.5 then 'AmEx-Processing' else 'AmEx' end
	end as Payment_Type,
	sum(Txn_Amount) Txn_Amount, sum(Revenue) Revenue, sum(Txn_Count) Txn_Count 
	from (
		select billing.Year, billing.Month , cast(dateadd(d, -1 , dateadd(mm, (Billing.Year - 1900) * 12 + Billing.Month, 0)) as date) as Date, billing.PlatformId , 
		c.Vertical , c.SoftwareName , c.ParentAccountId, c.ParentName , billing.PaymentType  ,
		sum(case when billing.PaymentType not in ('International Surcharge') then billing.Volume else 0 end) Txn_Amount,
		sum(billing.Charge) Revenue,
		sum(case when billing.PaymentType not in ('International Surcharge') then 1 else 0 end) Txn_Count
		from
			ETLStaging.dbo.PropertyPaidBilling billing
			inner join ETLStaging.dbo.FinanceParentTable c on billing.PlatformID = c.PlatformId and billing.ChildAccountID = c.ChildAccountId
		group by billing.Year, billing.Month,  cast(dateadd(d, -1 , dateadd(mm, (Billing.Year - 1900) * 12 + Billing.Month, 0)) as date), billing.PlatformId,
		c.Vertical, c.SoftwareName,c.ParentAccountId , c.ParentName , billing.PaymentType
	) src
group by Year, Month, Date, PlatformId, Vertical, SoftwareName, ParentAccountId, ParentName,
 	case when PaymentType in ('Visa','MasterCard','Discover','Debit','International Surcharge') then 'Card' when PaymentType in ('eCheck','e-Check','Scan','Scanned Checks') then 'ACH_Scan' when PaymentType in ('American Express','AmericanExpress','AmEx') then 
	case when Txn_Amount >= 200 and (Revenue / Txn_Amount)*100 > 1.5 then 'AmEx-Processing' else 'AmEx' end
	end
) src
where Date between @start and @end

if object_id('tempdb..#Txn') is not null drop table #Txn   
select year(txn.PostDate_R) Year, month(txn.PostDate_R) Month, cast(dateadd(d,  0, dateadd(d, -1 , dateadd(mm, (year(txn.PostDate_r) - 1900) * 12 + month(txn.PostDate_r) , 0))) as date) as Date, txn.PlatformId,
	c.Vertical , case when txn.ProcessorId in (14) then 'GatewayOnly' when txn.ProcessorId <> 14 then 'YapProcessing' end as Gateway_Type , c.SoftwareName, c.ParentAccountId , c.ParentName ,
	case when abs(txn.AmtNetConvFee) = 0 then 'PropertyPaid' when abs(txn.AmtNetConvFee) <> 0 then 'ConvFee' end as Fee_Payment_Type ,
	case  when pt.Name in ('Visa','Master Card','Discover','Visa Debit','MC Debit') then 'Card' when pt.Name in ('eCheck','Scan') then 'ACH_Scan'  when pt.Name in ('American Express') then case when txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) then 'AmEx-Processing' else 'AmEx' end  when pt.name in ('Cash') then 'Cash'     end as Payment_Type,
	cur.CharCode as Currency,
	sum(case when cycle.Type in ('Gross') then txn.Amount else 0 end) TPV, sum(case when cycle.Type in ('Gross') then txn.Amount else 0 end * fx.Rate) TPV_USD, sum(case when cycle.Type in ('Gross','Net')  then txn.Amount else 0 end) TPV_Net,sum(case when cycle.Type in ('Gross','Net')  then txn.Amount else 0 end * fx.Rate) TPV_Net_USD,
	sum(case when txn.PaymentTypeId in (1,2,3,11,12) and cycle.Type in ('Gross') then txn.Amount when txn.PaymentTypeId in (10) and txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) /* Amex , Bucket , Vantiv = Processing */ and cycle.Type in ('Gross')  then txn.Amount else 0 end * fx.Rate) Card_Volume_USD,
	sum(case when txn.PaymentTypeId in (1,2,3,11,12) and cycle.Type in ('Gross','Net') then txn.Amount when txn.PaymentTypeId in (10) and txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) /* Amex , Bucket , Vantiv = Processing */ and cycle.Type in ('Gross','Net')  then txn.Amount else 0 end * fx.Rate) Card_Volume_Net_USD,
	--sum(case when cycle.Type in ('Gross')  then 1 else 0 end) as Txn_Count,
	count(distinct(case when cycle.Type in ('Gross') then cast(left(txn.IdClassId, charindex(':', txn.IdClassId) -1 ) as varchar) + cast(txn.TransactionCycleId as varchar) else null end )) Txn_Count,      
	sum(case when cycle.Type in ('Gross','Net') then txn.AmtNetConvFee else 0 end) as Convenience_Fee, sum(case when cycle.Type in ('Gross','Net') then txn.AmtNetPropFee else 0 end) as Property_Fee, 
	sum(case when cycle.Type in ('Gross') then txn.AmtNetConvFee else 0 end * fx.Rate) as Convenience_Fee_USD, sum(case when cycle.Type in ('Gross') then txn.AmtNetPropFee else 0 end * fx.Rate) as Property_Fee_USD,
	sum(case when cycle.Type in ('Gross','Net') then txn.AmtNetConvFee else 0 end * fx.Rate) as Convenience_Fee_Net_USD, sum(case when cycle.Type in ('Gross','Net') then txn.AmtNetPropFee else 0 end * fx.Rate) as Property_Fee_Net_USD,
	sum(case when txn.PaymentTypeId in (1,2,3) and cycle.Type in ('Gross') then txn.Amount when txn.PaymentTypeId in (10) and txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) /* Amex , Bucket , Vantiv = Processing */ and cycle.Type in ('Gross')  then txn.Amount else 0 end * fx.Rate) Credit_Card_USD,
	sum(case when txn.PaymentTypeId in (11,12) and cycle.Type in ('Gross') then txn.Amount else 0 end * fx.Rate) Debit_Card_USD,
	sum(case when txn.PaymentTypeId in (10) and txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) /* Amex , Bucket , Vantiv = Processing */ and cycle.Type in ('Gross')  then txn.Amount else 0 end * fx.Rate) Amex_Processing_USD,
	sum(case when txn.PaymentTypeId in (1,2,3) and cycle.Type in ('Gross','Net') then txn.Amount when txn.PaymentTypeId in (10) and txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) /* Amex , Bucket , Vantiv = Processing */ and cycle.Type in ('Gross','Net')  then txn.Amount else 0 end * fx.Rate) Credit_Card_Net_USD,
	sum(case when txn.PaymentTypeId in (11,12) and cycle.Type in ('Gross','Net') then txn.Amount else 0 end * fx.Rate) Debit_Card_Net_USD	,
	sum(case when txn.PaymentTypeId in (10) and txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) /* Amex , Bucket , Vantiv = Processing */ and cycle.Type in ('Gross')  then txn.Amount else 0 end * fx.Rate) Amex_Processing_Net_USD
 into #Txn 
from  YapstoneDM.dbo.[Transaction] txn with (nolock)   
	inner join YapstoneDM.dbo.PaymentType pt with (nolock) on pt.PaymentTypeId = txn.PaymentTypeId
	inner join ETLStaging.dbo.FinanceParentTable c with (nolock) on c.PlatformId = txn.PlatformId and c.ChildCompanyId = txn.Ref_CompanyId 
	inner join YapstoneDM.dbo.Currency cur with (nolock) on cur.CurrencyId = txn.CurrencyId 
	inner join #Cycle cycle on cycle.TransactionCycleId = txn.TransactionCycleId
	inner join ETLStaging..FinanceFXRates fx on  txn.PostDate_R = fx.Date and txn.CurrencyId = fx.CurrencyId  
where
	txn.ProcessorId not in (16)   
	and txn.PostDate_R between  @start and @end
group by year(txn.PostDate_R), month(txn.PostDate_R), cast(dateadd(d,  0, dateadd(d, -1 , dateadd(mm, (year(txn.PostDate_r) - 1900) * 12 + month(txn.PostDate_r) , 0))) as date), txn.PlatformId,
	c.Vertical , case when txn.ProcessorId in (14) then 'GatewayOnly' when txn.ProcessorId <> 14 then 'YapProcessing' end , c.SoftwareName , c.ParentAccountId , c.ParentName ,
	case when abs(txn.AmtNetConvFee) = 0 then 'PropertyPaid' when abs(txn.AmtNetConvFee) <> 0 then 'ConvFee' end ,
	case  when pt.Name in ('Visa','Master Card','Discover','Visa Debit','MC Debit') then 'Card' when pt.Name in ('eCheck','Scan') then 'ACH_Scan'  when pt.Name in ('American Express') then case when txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) then 'AmEx-Processing' else 'AmEx' end  when pt.name in ('Cash') then 'Cash'     end ,
	cur.CharCode
			 
if object_id('tempdb..#MPRBase') is not null drop table #MPRBase   
select isnull(txn.Year, billing.Year) Year, isnull(txn.Month, billing.Month) Month, 
	cast(isnull(txn.Date, billing.Date) as varchar) Date, 
	isnull(txn.PlatformId,billing.PlatformId) PlatformId,isnull(txn.Gateway_Type,'YapProcessing') Gateway,
	isnull(txn.Vertical,billing.Vertical) Vertical, coalesce(txn.SoftwareName,billing.SoftwareName,'Non-Affiliated')  SoftwareName, isnull(txn.ParentAccountId,billing.ParentAccountId) as ParentAccountId,isnull(txn.ParentName,billing.ParentName) as ParentName ,
	isnull(txn.Fee_Payment_Type,'PropertyPaid') FeePaymentType ,isnull(txn.Payment_Type,billing.Payment_Type) PaymentTypeGroup ,isnull(txn.Currency,'USD') Currency,
	sum( txn.TPV ) TPV , sum( txn.TPV_Net) TPV_Net ,sum( txn.TPV_USD) TPV_USD ,sum( txn.TPV_Net_USD) TPV_Net_USD  ,sum( isnull(billing.Txn_Amount, 0) ) TPV_Billing ,
	sum( isnull(txn.Card_Volume_USD,0) ) Card_Volume_USD , sum( isnull(txn.Card_Volume_Net_USD,0)  ) Card_Volume_Net_USD ,
	sum( isnull(txn.Txn_Count,billing.Txn_Count)) as Txn_Count,
	sum( isnull( billing.Revenue, 0) ) as Property_Fee,sum( isnull(txn.Property_Fee_USD,0) ) Net_Settled_Fee_USD, sum( isnull(txn.Convenience_Fee_USD,0) ) as Convenience_Fee_USD,sum( isnull( billing.Revenue, 0) + isnull(txn.Property_Fee_USD,0) + isnull(txn.Convenience_Fee_USD,0) ) as Revenue_USD,sum( isnull( billing.Revenue, 0) + isnull(txn.Property_Fee_Net_USD,0) + isnull(txn.Convenience_Fee_Net_USD,0) ) as Revenue_Net_USD, 
	sum( isnull(txn.Property_Fee_Net_USD,0) ) Net_Settled_Fee_Net_USD,sum( isnull(txn.Convenience_Fee_Net_USD,0) ) as Convenience_Fee_Net_USD,
	sum( isnull(txn.Credit_Card_USD,0) ) Credit_Card_USD, sum(isnull(txn.Debit_Card_USD, 0) ) Debit_Card_USD, sum(isnull(txn.Amex_Processing_USD,0)) Amex_Processing_USD,
	sum( isnull(txn.Credit_Card_Net_USD,0) ) Credit_Card_Net_USD, sum(isnull(txn.Debit_Card_Net_USD, 0) ) Debit_Card_Net_USD, sum(isnull(txn.Amex_Processing_Net_USD,0)) Amex_Processing_Net_USD
	into #MPRBase
from
	#txn Txn    
	full outer join #Billing billing on billing.Year = txn.Year and billing.Month = txn.Month  and billing.PlatformId = txn.PlatformId and billing.ParentAccountId = txn.ParentAccountId and txn.Fee_Payment_Type = 'PropertyPaid'  
		and txn.Payment_Type = billing.Payment_Type and txn.Gateway_Type = 'YapProcessing'
group by      
	isnull(txn.Year, billing.Year) ,isnull(txn.Month, billing.Month) , 
	cast(isnull(txn.Date, billing.Date) as varchar), 
	isnull(txn.PlatformId,billing.PlatformId), isnull(txn.Gateway_Type,'YapProcessing') ,
	isnull(txn.Vertical,billing.Vertical) , coalesce(txn.SoftwareName,billing.SoftwareName,'Non-Affiliated') , isnull(txn.ParentAccountId,billing.ParentAccountId) ,isnull(txn.ParentName,billing.ParentName) , 
	isnull(txn.Fee_Payment_Type,'PropertyPaid') ,isnull(txn.Payment_Type,billing.Payment_Type) ,isnull(txn.Currency,'USD')


select * from #MPRBase

--select 
--	PlatformId, 
--	convert(varchar,cast(sum(TPV_USD) as money),1) TPV_USD , 
--	convert(varchar,cast(sum(Card_Volume_USD) as money),1) Card_Volume_USD ,	
--	convert(varchar,cast(sum(Revenue_USD) as money),1) Revenue_USD,
--	convert(varchar,cast(sum(Txn_Count) as money),1) Txn_Count	
--from 
--	#BaseMPR
--where
--	Gateway in ('YapProcessing')
--group by
--	Platformid      
--order by
--	PlatformId
