declare @now as date, @start as date, @end as date

set @now = getdate()
set @start = '2010-01-01'--dateadd(mm,(year(@now)- 1900) * 12 + month(@now) - 1 -1 , 0) 
set @end = dateadd(d,-1 , dateadd(mm,(year(@now)- 1900) * 12 + month(@now)- 1 , 0))  

if object_id('tempdb..#ExternalGateway') is not null drop table #ExternalGateway
select * into #ExternalGateway from (
	select 
		Year, Month, cast(dateadd(d, -1 , dateadd(mm, (Year - 1900) * 12 + Month, 0)) as date) as Date,
		sum(Txn_Amount) as TPV
	from 
		ETLStaging..FinanceExtGatewayVolume
	group by 
		Year, Month, cast(dateadd(d, -1 , dateadd(mm, (Year - 1900) * 12 + Month, 0)) as date)
) src

select * from #ExternalGateway


