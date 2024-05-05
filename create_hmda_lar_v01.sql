# hmda
#
drop table if exists hmda_lar;
create table hmda_lar (
 activity_year char(4) not null, # 001
 lei char(20) not null, # 002
 derived_msa_md char(5) not null, # 003
 state_code char(2) , # 004
 county_code char(5) , # 005
 census_tract char(11) , # 006
 conforming_loan_limit char(2) , # 007
 derived_loan_product_type varchar(29) not null, # 008
 derived_dwelling_category varchar(38) not null, # 009
 purchaser_type /*
    0 - Not applicable
    1 - Fannie Mae
    2 - Ginnie Mae
    3 - Freddie Mac
    4 - Farmer Mac
    5 - Private securitizer
    6 - Commercial bank, savings bank, or savings association
    71 - Credit union, mortgage company, or finance company
    72 - Life insurance company
    8 - Affiliate institution
    9 - Other type of purchaser */
    enum('0','1','2','3','4','5','6,','71','72','8','9'), # 014
 loan_type /* 
    1 - Conventional (not insured or guaranteed by FHA, VA, RHS, or FSA)
    2 - Federal Housing Administration insured (FHA)
    3 - Veterans Affairs guaranteed (VA)
    4 - USDA Rural Housing Service or Farm Service Agency guaranteed (RHS or FSA) */
     enum('1','2','3','4'), # 016
 loan_purpose /*
    1 - Home purchase
    2 - Home improvement
    31 - Refinancing
    32 - Cash-out refinancing
    4 - Other purpose
    5 - Not applicable */
    enum('1','2','31','32','4','5') , # 017
 loan_amount decimal(8,0) not null, # 022
 combined_loan_to_value_ratio double, # 023
 interest_rate double, # 024
 rate_spread double, # 025
 loan_term int , # 032 bad data, like 999 or 360360
 property_value decimal(10,0) , # 039
 occupancy_type /*
    1 - Principal residence
    2 - Second residence
    3 - Investment property */
    enum('1','2','3'), # 041
 total_units /*
    1
    2
    3
    4
    5-24
    25-49
    50-99
    100-149
    >149  */
    enum('1','2','3','4','5-24','25-49','50-99','100-149','>149'), # 044
 income decimal(12,0) , # 046 (in thousands)
 debt_to_income_ratio varchar(10), # 047
 tract_minority_population_percent double, # 094
 ffiec_msa_md_median_family_income decimal(7,0), # 095
 tract_to_msa_income_percentage decimal(5,1) # 096
);
