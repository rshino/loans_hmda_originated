CREATE TABLE statistical_area_delineation (
       cbsa_code  char(5) NOT NULL, 
       metrodiv_code char(5) NULL,  
       csa_code char(3) NULL,       
       cbsa_title varchar(80) NOT NULL,
       area_type enum('Metropolitan Statistical Area',
       		 'Micropolitan Statistical Area') not null,
	metrodiv_title varchar(80) null,
	csa_title varchar(80) null,
	county varchar(80) null,
	state_name varchar(80) not null,
	fips_state_code char(2) not null,
	fips_county_code char(3) not null,
	county_type enum('Central','Outlying') not null,
	delineation_year char(4) not null,
  KEY year_cbsa_metrodiv_year_IDX (cbsa_code,metrodiv_code,delineation_year)
);
