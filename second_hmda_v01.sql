select
census_tract as region
, second_home_pct as value
from
(
	select census_tract
	, sum(case when occupancy_type = '2' then loan_amount else 0 end)
	/ sum(loan_amount) as second_home_pct
	from hmda_lar
	where activity_year=2022
	and loan_type='1' # conventional
	and total_units in ('1','2','3','4') # 1-4 units
	and loan_purpose in ('1','31','32') # P, R, C
	and occupancy_type is not null
	and census_tract is not null
	group by census_tract
) grouped
