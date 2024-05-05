#include "format_v01.cpp"
select
	group_concat(distinct activity_year) as Year
	/*_BYCT_ ,census_tract _BYCT_*/
#ifdef ROLL
	/*_BYSELL_ ,case when grouping(seller)=1 then 'Total' 
		   else seller end as seller _BYSELL_*/
#ifdef BYSELL
	/*_W_LEI_ , case when grouping(seller)=1 then 'Total'
		  else group_concat(distinct hmda_lar.lei) end as lei _W_LEI_*/
#endif
#else
	/*_BYSELL_ ,seller as seller _BYSELL_*/
#ifdef BYSELL	
	/*_W_LEI_ , group_concat(distinct hmda_lar.lei) as lei _W_LEI_*/
#endif
#endif
#if defined(BYCT) && defined(F_LEI)
#ifdef ROLL
	,case when grouping(census_tract)=1 then 'Total' 
		   else group_concat(distinct seller) end as seller 
	,case when grouping(census_tract)=1 then 'Total' 
		   else group_concat(distinct hmda_lar.lei) end as lei
#else
	,group_concat(distinct seller) as seller
	,group_concat(distinct hmda_lar.lei) as lei		   
#endif
#endif
	, FC(count(*)) as Loans
	, FC(sum(loan_amount)) as UPB
	, FC(avg(loan_amount)) as ALS
	, FC(avg(combined_loan_to_value_ratio)) as CLTV
	, FC(avg(debt_to_income_ratio)) as DTI
	, FP(sum(case when loan_purpose = '32' then 1 else 0 end)
	  / count(*)) 		as cashout_pct
	, FP(sum(case when occupancy_type = '2' then 1 else 0 end)
	  / count(*)) 		as second_home_pct
	, FP(sum(case when
	income*1000 < (ffiec_msa_md_median_family_income*0.80)
	then 1 else 0 end )
	     / count(*))		as lmi_pct
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
      /*_YEAR_ and activity_year=YEAR _YEAR_*/
      /*_YEARS_ and activity_year in (YEARS) _YEARS_*/
      and loan_amount is not null
      and combined_loan_to_value_ratio is not null
      and debt_to_income_ratio is not null
      /*_PURCH_ and loan_purpose in ('1') _PURCH_*/
      /*_PURREFI_    and loan_purpose in ('1','31','32') _PURREFI_*/
      and occupancy_type is not null
      /*_CONV_ and loan_type='1' _CONV_*/
      /*_CONF_ and conforming_loan_limit = 'C' _CONF_*/
      /*_ST_ and state_code = '_ST_' _ST_*/
      /*_LGST_ and Legal_Jurisdiction = concat('US-_LGST_') _LGST_*/
      /*_F_LEI_ and hmda_lar.lei='_F_LEI_' _F_LEI_*/
      and total_units in ('1','2','3','4') # 1-4 units
      and census_tract REGEXP '^[0-9]+$'
group by
      /*_BYCT_ census_tract _BYCT_*/
      /*_BYSELL_ seller _BYSELL_*/
      /*_MINCOUNT_ having count(*) >= _MINCOUNT_ _MINCOUNT_*/
      /*_ROLL_ with rollup _ROLL_*/
#if defined(ORD2HOM) || defined(ORDLMI)
order by
      group_concat(distinct activity_year)
#ifdef ROLL
      /*_BYCT_ ,grouping(census_tract) _BYCT_*/
      /*_BYSELL_ ,grouping(seller) _BYSELL_*/
#endif
      /*_ORD2HOM_ 
	,sum(case when occupancy_type = '2' then 1 else 0 end) / count(*) DESC
      _ORD2HOM_*/
      /*_ORDLMI_ 
	, sum(case when
	income*1000 < (ffiec_msa_md_median_family_income*0.80)
	then 1 else 0 end ) / count(*)) DESC
      _ORDLMI_*/      
#endif

--
--
