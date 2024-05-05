select
census_tract as region
, cashout_pct as value
from
(
	select census_tract
	, sum(case when loan_purpose = '32' then loan_amount else 0 end)
	/ sum(loan_amount) as cashout_pct
	from hmda_lar
	where activity_year=2022
	and loan_type='1' # conventional
	and total_units in ('1','2','3','4') # 1-4 units
	and loan_purpose in ('1','31','32') # P, R, C
	and occupancy_type is not null
	and census_tract is not null
	group by census_tract
) grouped
