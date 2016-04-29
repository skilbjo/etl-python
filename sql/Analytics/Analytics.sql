-- Analytics Report
declare @now as date, @start as date, @end as date, 
@PaymentTypeGroup as nvarchar(max), @Network as nvarchar(max)

set @now = getdate()
set @start = dateadd(mm,(year(@now)- 1900) * 12 + month(@now) - 1 -1 , 0) 
set @end = dateadd(d,-1 , dateadd(mm,(year(@now)- 1900) * 12 + month(@now)- 1 , 0))  

-- Temp Tables
if object_id('tempdb..#PaymentTypeGroup') is not null drop table #PaymentTypeGroup
create table #PaymentTypeGroup (PaymentType nvarchar(max), PaymentTypeGroup nvarchar(max))
if object_id('tempdb..#Network') is not null drop table #Network
create table #Network (PaymentType nvarchar(max), Network nvarchar(max))
if object_id('tempdb..#Analytics') is not null drop table #Analytics

set @PaymentTypeGroup = '
insert into #PaymentTypeGroup select ''Discover'',''Credit''
insert into #PaymentTypeGroup select ''NYCE'',''Debit''
insert into #PaymentTypeGroup select ''Master Card'',''Credit''
insert into #PaymentTypeGroup select ''Visa'',''Credit''
insert into #PaymentTypeGroup select ''American Express'',''AmEx''
insert into #PaymentTypeGroup select ''Pulse'',''Debit''
insert into #PaymentTypeGroup select ''Visa Debit'',''Debit''
insert into #PaymentTypeGroup select ''Cash'',''Cash''
insert into #PaymentTypeGroup select ''eCheck'',''ACH''
insert into #PaymentTypeGroup select ''Star'',''Debit''
insert into #PaymentTypeGroup select ''Scan'',''ACH''
insert into #PaymentTypeGroup select ''Debit Card'',''Debit''
insert into #PaymentTypeGroup select ''MC Debit'',''Debit'''

set @Network = '
insert into #Network select ''Discover'',''Discover''
insert into #Network select ''Master Card'',''Mastercard''
insert into #Network select ''Visa'',''Visa''
insert into #Network select ''American Express'',''Amex''
insert into #Network select ''MC Debit'',''Mastercard''
insert into #Network select ''Visa Debit'',''Visa'''

exec sp_executesql @PaymentTypeGroup
exec sp_executesql @Network

select 
	year(txn.PostDate_r) Year ,month(txn.PostDate_r) Month,
	cast(cast(dateadd(d,  0, dateadd(d, -1 , dateadd(mm, (year(txn.PostDate_r) - 1900) * 12 + month(txn.PostDate_r) , 0))) as date) as varchar) as Date, txn.PlatformId,case	when txn.ProcessorId = 14 then 'GatewayOnly' else 'YapProcessing' end as Gateway,
	c.Vertical ,pt.Name PaymentType ,Network.Network,ptg.PaymentTypeGroup ,cur.CharCode Currency,
	sum(case when txn.TransactionCycleId in (1) then txn.amount else 0 end) TPV,
	sum(case when txn.TransactionCycleId in (1) then txn.amount else 0 end
		* fx.Rate
	) TPV_USD	,
	--sum(case when txn.TransactionCycleId in (1) then 1 else 0 end) as Txn_Count,
	count(distinct(case when txn.TransactionCycleId in (1) then cast(left(txn.IdClassId, charindex(':', txn.IdClassId) -1 ) as varchar) + cast(txn.TransactionCycleId as varchar) else null end )) Txn_Count,      
	sum(case when txn.paymenttypeid in (1, 2, 3, 11, 12, /* <-- regular cards */ /* pre 2012 debit networks --> */  6,7,8,9) and txn.TransactionCycleId in (1) then txn.Amount 
			when txn.PaymentTypeId in (10) and txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) /* Amex , Bucket , Vantiv = Processing */ and txn.TransactionCycleId in (1) then txn.Amount
		else 0 end) as Card_Volume,
	--sum(case when txn.paymenttypeid in (1, 2, 3, 11, 12, /* <-- regular cards */ /* pre 2012 debit networks --> */  6,7,8,9) and txn.TransactionCycleId in (1) then 1 
	--		when txn.PaymentTypeId in (10) and txn.ProcessorId in (22)  and txn.Ref_BatchTypeId in (1) /* Amex , Bucket , Vantiv = Processing */ and txn.TransactionCycleId in (1) then 1
	--	else 0 end) Card_Txn_Count,
	count(distinct(case when txn.paymenttypeid in (1, 2, 3, 11, 12, /* <-- regular cards */ /* pre 2012 debit networks --> */  6,7,8,9) and txn.TransactionCycleId in (1) then cast(left(txn.IdClassId, charindex(':', txn.IdClassId) -1 ) as varchar) + cast(txn.TransactionCycleId as varchar) 
			when txn.PaymentTypeId in (10) and txn.ProcessorId in (22)  and txn.Ref_BatchTypeId in (1) /* Amex , Bucket , Vantiv = Processing */ and txn.TransactionCycleId in (1) then cast(left(txn.IdClassId, charindex(':', txn.IdClassId) -1 ) as varchar) + cast(txn.TransactionCycleId as varchar)
		else null end)) Card_Txn_Count,
	sum(case when txn.paymenttypeid in (1, 2, 3, 11, 12, /* <-- regular cards */ /* pre 2012 debit networks --> */  6,7,8,9) and txn.TransactionCycleId in (1) then txn.Amount 
			when txn.PaymentTypeId in (10) and txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) /* Amex , Bucket , Vantiv = Processing */ and txn.TransactionCycleId in (1) then txn.Amount
		else 0 end
		* fx.Rate
	) as Card_Volume_USD	
	into #Analytics   								
from   
	YapstoneDM.dbo.[Transaction] txn with (nolock)  								
	inner join ETLStaging.dbo.FinanceParentTable c on txn.PlatformId = c.PlatformId and txn.Ref_CompanyId = c.ChildCompanyId		
	inner join YapstoneDM.dbo.Currency on txn.CurrencyId = Currency.CurrencyId		    								
	inner join YapstoneDM.dbo.PaymentType pt with (nolock) on txn.PaymentTypeId = pt.PaymentTypeId 	
	left join #PaymentTypeGroup ptg on pt.Name = ptg.PaymentType		
	left join #Network Network on pt.Name = Network.PaymentType					
	inner join YapstoneDM.dbo.Currency cur with (nolock) on txn.CurrencyId = cur.CurrencyId 
	inner join ETLStaging..FinanceFXRates fx on  txn.PostDate_R = fx.Date and txn.CurrencyId = fx.CurrencyId  													
where    
	txn.PostDate_r between @start and @end								
	and txn.TransactionCycleId in (1) 					
	and txn.ProcessorId not in (16)					
group by  
	year(txn.PostDate_r), month(txn.PostDate_r) , 
	cast(cast(dateadd(d,  0, dateadd(d, -1 , dateadd(mm, (year(txn.PostDate_r) - 1900) * 12 + month(txn.PostDate_r) , 0))) as date) as varchar),txn.PlatformId, case when txn.ProcessorId = 14 then 'GatewayOnly' else 'YapProcessing' end ,							
	c.Vertical ,pt.Name ,cur.CharCode ,Network.Network ,ptg.PaymentTypeGroup
	
select * from #Analytics	
	
-- select 
-- 	PlatformId, 
-- 	convert(varchar,cast(sum(TPV_USD) as money),1) TPV_USD , 
-- 	convert(varchar,cast(sum(Card_Volume_USD) as money),1) Card_Volume_USD ,
-- 	convert(varchar,cast(sum(Txn_Count) as money),1) Txn_Count,
-- 	convert(varchar,cast(sum(Card_Txn_Count) as money),1) Card_Txn_Count	
-- from 
-- 	#Analytics
-- where
-- 	Gateway in ('YapProcessing')
-- group by
-- 	Platformid      
-- order by
-- 	PlatformId
