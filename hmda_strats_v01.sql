
select
	census_tract
	, avg(loan_amount) as ALS
	, avg(combined_loan_to_value_ratio) as CLTV
	, avg(debt_to_income_ratio) as DTI
	, sum(case when loan_purpose = '32' then 1 else 0 end)
	/ count(*) 		as cashout_pct
	, sum(case when occupancy_type = '2' then 1 else 0 end)
	/ count(*) 		as second_home_pct
	, sum(case when
	income*1000 < (ffiec_msa_md_median_family_income*0.80)
	then 1 else 0 end )
	/ count(*)		as lmi_pct
from hmda_lar
where 1=1
      and activity_year=2022
      and loan_amount is not null
      and combined_loan_to_value_ratio is not null
      and debt_to_income_ratio is not null
      and loan_purpose in ('1','31','32') # P, R, C
      and occupancy_type is not null
      and loan_type='1' # conventional
      and total_units in ('1','2','3','4') # 1-4 units
      and census_tract is not null
group by census_tract

