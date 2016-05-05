declare @now as date, @start as date, @end as date , @date as nvarchar(max) , @query as nvarchar(max)
set @now = getdate()
set @start = dateadd(mm,(year(@now)- 1900) * 12 + month(@now) - 1 -1 , 0)
set @end = dateadd(d,-1 , dateadd(mm,(year(@now)- 1900) * 12 + month(@now)- 1 , 0)) 
      
 
if object_id('tempdb..#MMF') is not null drop table #MMF 
select * into #MMF from (
select
    cast(cast(dateadd(d, -1 , dateadd(mm, (left(cast(billing.yearmonth as varchar(6)), 4) - 1900) * 12 + cast(substring(cast(billing.yearmonth as varchar(6)),5,2) as int), 0)) as date) as varchar) as Date,  
    case when billing.server in ('V2') then 1 when billing.server in ('IP') then 2 when billing.server in ('HA') then 3 end PlatformId,
    c.Vertical, c.ParentAccountId , c.ParentName ,
    sum(billing.TotalCharge) MMF
from
    ETLStaging.dbo.GMR_PropertyPaidBillingType billing with (nolock)
    inner join ETLStaging.dbo.FinanceParentTable c on  (case when billing.server in ('V2') then 1 when billing.server in ('IP') then 2 when billing.server in ('HA') then 3 end) = c.PlatformId
              and c.ChildAccountId = billing.AccountId
where
    billing.Server in ('V2','IP','HA')
    and billing.BillingType in ('MaintFee')
    and ( case when billing.Server in ('HA') and billing.CompanyId in (1009, 70635, 1244) then 1
               when billing.Server in ('V2','IP') then 1 else 0    end ) = 1  -- HA TripCancellationProtection, etco. Main property owners are net settled and rev already include in txn table
    and billing.BT_CompanyName <> 'T  R  Lawing Realty Inc' -- These guys are billing but accounting throws away the invoices as they haven't started processing. Needs to be excluded manually.
group by   
    cast(cast(dateadd(d, -1 , dateadd(mm, (left(cast(billing.yearmonth as varchar(6)), 4) - 1900) * 12 + cast(substring(cast(billing.yearmonth as varchar(6)),5,2) as int), 0)) as date) as varchar) ,
    case when billing.server in ('V2') then 1 when billing.server in ('IP') then 2 when billing.server in ('HA') then 3 end,
    c.Vertical, c.ParentAccountId , c.ParentName
 ) src where Date between @start and @end
 
 
 select * from #mmf 
 
