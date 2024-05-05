select
cbsa_code
,cbsa_title
,metrodiv_code
,metrodiv_title
,state_name
, county
, fips_state_code
, fips_county_code
, concat(fips_state_code, fips_county_code) state_county_code
from statistical_area_delineation
where cbsa_code in (15380,40380,35620,37980,12100)
order by state_county_code; 
