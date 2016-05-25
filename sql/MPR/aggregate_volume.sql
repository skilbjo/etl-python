
declare @now as date, @start as date, @end as date, 
@PaymentTypeGroup as nvarchar(max) 

set @now = getdate()
set @start = '2014-01-01'--dateadd(mm,(year(@now)- 1900) * 12 + month(@now) - 1 -1 , 0) 
set @end = '2016-03-31'--dateadd(d,-1 , dateadd(mm,(year(@now)- 1900) * 12 + month(@now)- 1 , 0))  

-- Temp Tables
if object_id('tempdb..#PaymentTypeGroup') is not null drop table #PaymentTypeGroup
create table #PaymentTypeGroup (PaymentType nvarchar(max), PaymentTypeGroup nvarchar(max))
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
exec(@PaymentTypeGroup)

if object_id('tempdb..#Cycle') is not null drop table #Cycle
select * into #Cycle from (
	select 1 TransactionCycleId,	'Gross' Type union
	select 3,	'Net' union
	select 4,	'Net' union
	select 9,	'Net' union
	select 16,	'Net' 
) src

if object_id('tempdb..#Query') is not null drop table #Query
select * into #Query from (
	select
		cast(cast(dateadd(d,  0, dateadd(d, -1 , dateadd(mm, (year(txn.PostDate_r) - 1900) * 12 + month(txn.PostDate_r) , 0))) as date) as varchar) as Date,
		txn.PlatformId , c.ParentAccountId, c.ParentName , c.DateFirstSeen ,
		case	when txn.ProcessorId = 14 then 'GatewayOnly' else 'YapProcessing' end as Gateway,
		case when abs(txn.AmtNetConvFee) = 0 then 'PropertyPaid' when abs(txn.AmtNetConvFee) <> 0 then 'ConvFee' end as FeePaymentType ,
		i.CardType IssuerType, 
		case when txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) then 'AmEx-Processing' else ptg.PaymentTypeGroup end as PaymentTypeGroup, 
		sum(case when tc.Type in ('Gross') then txn.Amount else 0 end) as TPV_USD, sum(txn.Amount) as TPV_Net_USD
	from
		YapstoneDM..[Transaction] txn
		join ETLStaging..FinanceParentTable c on txn.PlatformId = c.PlatformId and txn.Ref_CompanyId = c.ChildCompanyId
		join ETLStaging..FinanceIssuerType i on txn.PlatformId = i.PlatformId and txn.IdClassId = i.IdClassId
		join YapstoneDM.dbo.PaymentType pt with (nolock) on txn.PaymentTypeId = pt.PaymentTypeId 
		left join #PaymentTypeGroup ptg on pt.Name = ptg.PaymentType
		join #Cycle tc on txn.TransactionCycleId = tc.TransactionCycleId
	where
		txn.PlatformId in (1,2,3)
		and txn.PostDate_R between @start and @end
		and txn.ProcessorId not in (16)
	group by
		cast(cast(dateadd(d,  0, dateadd(d, -1 , dateadd(mm, (year(txn.PostDate_r) - 1900) * 12 + month(txn.PostDate_r) , 0))) as date) as varchar),
		txn.PlatformId , c.ParentAccountId , c.ParentName, c.DateFirstSeen ,
		case	when txn.ProcessorId = 14 then 'GatewayOnly' else 'YapProcessing' end ,
		case when abs(txn.AmtNetConvFee) = 0 then 'PropertyPaid' when abs(txn.AmtNetConvFee) <> 0 then 'ConvFee' end  ,
		i.CardType , 
		case when txn.ProcessorId in (22) and txn.Ref_BatchTypeId in (1) then 'AmEx-Processing' else ptg.PaymentTypeGroup end
)  src


select * from #Query

