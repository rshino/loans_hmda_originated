select
census_tract as region
, lmi_pct as value
from
(
	select census_tract
	, sum(case when
	income*1000 < (ffiec_msa_md_median_family_income*0.80)
	then 1 else 0 end )
	/ count(*) as lmi_pct
	from hmda_lar
	where activity_year=2022
	and loan_type='1' # conventional
	and total_units in ('1','2','3','4') # 1-4 units
	and loan_purpose in ('1','31','32') # P, R, C
	and occupancy_type is not null
	and census_tract is not null
	group by census_tract
) grouped
