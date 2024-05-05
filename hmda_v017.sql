-- hmda
-- v11 added grouping by state
-- v12
-- v14
-- F_<x> filter by x
-- X_<x> exclude x
-- BY_<x> group by x
-- D_<x> display x
-- O_<x> order by x

#include "format_v01.cpp"

#	ifdef ROLL
#	  define GF(p) case when grouping(p)=1 then 'Total' else p end  
#	else ndef ROLL
#	  define GF(p) p 
#	endif ROLL

select
	group_concat(distinct activity_year) as Year
#	ifdef D_ST
	,group_concat(distinct state_code) as State
#  	endif D_ST	
	/*_BY_CT_ ,census_tract _BY_CT_*/
 	/*_BY_ST_ ,GF(state_code) as state_code _BY_ST_*/
#	ifdef ROLL

	/*_BY_SELL_ ,case when grouping(seller)=1 then 'Total' 
		   else seller end as seller _BY_SELL_*/
#	ifdef BY_SELL
	/*_D_LEI_ , case when grouping(seller)=1 then 'Total'
		  else group_concat(distinct hmda_lar.lei) end as lei _D_LEI_*/
#	endif BY_SELL
#	else
	/*_BY_SELL_ ,seller as seller _BY_SELL_*/
#	ifdef BY_SELL	
	/*_D_LEI_ , group_concat(distinct hmda_lar.lei) as lei _D_LEI_*/
#	endif BY_SELL
#	endif ROLL
#	if defined(BY_CT) && defined(F_LEI)
#	ifdef ROLL

	,case when grouping(census_tract)=1 then 'Total' 
		   else group_concat(distinct seller) end as seller 
	,case when grouping(census_tract)=1 then 'Total' 
		   else group_concat(distinct hmda_lar.lei) end as lei
#	else
	,group_concat(distinct seller) as seller
	,group_concat(distinct hmda_lar.lei) as lei		   
#	endif ROLL
#	endif BY_SELL
	/*_BY_2HOM_ ,GF(occupancy_type) as occupancy_type _BY_2HOM_*/
	, FC(count(*)) as Loans
	, FC(sum(loan_amount)) as UPB
	, FP(sum(case when loan_type = '1' then 1 else 0 end)
	  / count(*)) 		as conv_pct
	, FP(sum(case when loan_type in ('2','3','4') then 1 else 0 end)
	  / count(*)) 		as govt_pct
#	ifdef D_RISK	
	, FC(avg(loan_amount)) as ALS
	, FC(avg(combined_loan_to_value_ratio)) as CLTV
	, FC(avg(debt_to_income_ratio)) as DTI
#	endif D_RISK
#	ifdef D_SALE
	,FP(sum(case when purchaser_type = '0' then 1 else 0 end )
	/ count(*)) as 	  retain_pct
	,FP(sum(case when purchaser_type in ('1','2','3','4') then 1 else 0 end )
	/ count(*)) as 	  sale_gse_pct
	,FP(sum(case when purchaser_type in ('5') then 1 else 0 end )
	/ count(*)) as 	  sale_plmbs_pct
	,FP(sum(case when purchaser_type in ('6','71','72','8','9') 
		    then 1 else 0 end )
	/ count(*)) as 	   sale_other_pct
#	endif D_SALE

#	ifdef D_GEO
	, FP(sum(case when state_code = 'NY' then 1 else 0 end)
	  / count(*)) 		as ny_pct
	, FP(sum(case when state_code = 'NJ' then 1 else 0 end)
	  / count(*)) 		as nj_pct
	, FP(sum(case when state_code = 'PA' then 1 else 0 end)
	  / count(*)) 		as pa_pct
	, FP(sum(case when state_code = 'CT' then 1 else 0 end)
	  / count(*)) 		as ct_pct
	, FP(sum(case when state_code = 'MA' then 1 else 0 end)
	  / count(*)) 		as ma_pct
	, FP(sum(case when state_code = 'VT' then 1 else 0 end)
	  / count(*)) 		as vt_pct
	, FP(sum(case when state_code = 'DE' then 1 else 0 end)
	  / count(*)) 		as de_pct
	, FP(sum(case when state_code = 'MD' then 1 else 0 end)
	  / count(*)) 		as md_pct
	, FP(sum(case when state_code = 'CA' then 1 else 0 end)
	  / count(*)) 		as ca_pct
	, FP(sum(case when state_code = 'FL' then 1 else 0 end)
	  / count(*)) 		as fl_pct
	, FP(sum(case when state_code = 'TX' then 1 else 0 end)
	  / count(*)) 		as tx_pct
#	endif D_GEO	  
#	ifdef D_RISK
	, FP(sum(case when loan_purpose = '32' then 1 else 0 end)
	  / count(*)) 		as cashout_pct
	, FP(sum(case when occupancy_type = '2' then 1 else 0 end)
	  / count(*)) 		as second_home_pct
#	endif D_RISK
#	ifdef D_HGOAL
	, FP(sum(case when
	income*1000 < (ffiec_msa_md_median_family_income*0.80)
	then 1 else 0 end )
	     / count(*))		as lmi_pct
	, FP(sum(case when tract_minority_population_percent > 30
	then 1 else 0 end )
	     / count(*))		as "min.tract_pct"
#	endif D_HGOAL	     
from hmda_lar
join
(select
	lei
	,concat(Legal_Name,', '
	,coalesce(Legal_City,'n/a'),', '
	,Legal_Jurisdiction)
		as seller
	,Legal_Jurisdiction
from lei_lookup
) lei_desc
on hmda_lar.lei = lei_desc.LEI
where 1=1
--    -------
--    FILTERS
--    -------
      /*_F_YEAR_ and activity_year=F_YEAR _F_YEAR_*/
      /*_F_YEARS_ and activity_year in (F_YEARS) _F_YEARS_*/
      /*_F_PURCH_ and loan_purpose in ('1') _F_PURCH_*/
      /*_F_PURREFI_    and loan_purpose in ('1','31','32') _F_PURREFI_*/
      /*_F_CONV_ and loan_type='1' _F_CONV_*/
      /*_F_CONF_ and conforming_loan_limit = 'C' _F_CONF_*/
      /*_F_ST_ and state_code = '_F_ST_' _F_ST_*/
      /*_F_LGST_ and Legal_Jurisdiction = concat('US-_F_LGST_') _F_LGST_*/
      /*_F_LEI_ and hmda_lar.lei='_F_LEI_' _F_LEI_*/
      /*_F_2HOM_ and occupancy_type = '2' _F_2HOM_*/
      /*_F_LMI_ and income*1000 < (ffiec_msa_md_median_family_income*0.80) _F_LMI_*/
      /*_X_ST_ and state_code <> '_X_ST_' _X_ST_*/
      /*_X_LGST_ and Legal_Jurisdiction <> concat('US-_X_LGST_') _X_LGST_*/
--    "normalizing" filters      
      and census_tract REGEXP '^[0-9]+$'
      and combined_loan_to_value_ratio is not null
      and conforming_loan_limit is not null
      and debt_to_income_ratio is not null
      and ffiec_msa_md_median_family_income is not null
      and Legal_Jurisdiction is not null
      and loan_amount is not null
      and loan_type is not null
      and occupancy_type is not null
      and state_code is not null
      and total_units in ('1','2','3','4') # 1-4 units
      and tract_minority_population_percent is not null
group by
--    GROUP by ONLY ONE
      /*_BY_CT_ census_tract _BY_CT_*/
      /*_BY_SELL_ seller _BY_SELL_*/
      /*_BY_ST_ state_code _BY_ST_*/
--    level 2 group
      /*_BY_2HOM_ ,occupancy_type _BY_2HOM_*/
--    ROLLUP      
      /*_ROLL_ with rollup _ROLL_*/
--    COUNT cutoffs
      /*_MINCOUNT_ having count(*) >= _MINCOUNT_ _MINCOUNT_*/
--    ORDER      
#     if defined(O_2HOM) || defined(O_LMI) || defined(O_LOANCT)
order by
      group_concat(distinct activity_year)
#     ifdef ROLL
      /*_BY_CT_ ,grouping(census_tract) _BY_CT_*/
      /*_BY_SELL_ ,grouping(seller) _BY_SELL_*/
#     endif
      /*_O_LOANCT_
	,count(*) DESC
	_O_LOANCT_*/
      /*_O_2HOM_ 
	,sum(case when occupancy_type = '2' then 1 else 0 end) / count(*) DESC
      _O_2HOM_*/
      /*_O_LMI_ 
	, sum(case when
	income*1000 < (ffiec_msa_md_median_family_income*0.80)
	then 1 else 0 end ) / count(*) DESC
      _O_LMI_*/      
#     endif

--
--
