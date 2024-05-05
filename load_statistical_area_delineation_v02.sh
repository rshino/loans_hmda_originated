#!/usr/bin/bash
# load_cmast_v02.sh <file>
# e.g., load_cmast_v01.sh state_Oct2023.csv
#
#       cbsa_code  char(5) NOT NULL,
#       metrodiv_code char(5) NULL,
#       csa_code char(3) NULL,
#       cbsa_title varchar(80) NOT NULL,
#       area_type enum('Metropolitan Statistical Area',
#       		 'Micropolitan Statistical Area') not null,
#	metrodiv_title varchar(80) null,
#	csa_title varchar(80) null,
#	county varchar(80) null,
#	state_name varchar(80) not null,
#	fips_state_code char(2) not null,
#	fips_county_code char(3) not null,
#	county_type enum('Central','Outlying') not null,
#	delineation_year char(4) not null,
#

DBNAME=loans
TABLENAME=statistical_area_delineation
if [ "$1" = "-n" ] ; then
   unset LOADFILE;shift 1
   else LOADFILE='Y'
fi
if [ $# -eq 0 ]; then echo "usage: $0 [-n] <file>"; exit 1;fi
export INFILE="${1}"

if [ -f "${INFILE}" ]
then
    export YEAR=$(echo "${INFILE}" | sed 's/^.*\([0-9][0-9][0-9][0-9]\).*$/\1/' )
    cat "${INFILE}" | head -n -3 | sed 's/$/\t'${YEAR}'/' > _"${INFILE}"
    if [ "${LOADFILE}" = "Y" ]
    then
	echo "LOADING _${INFILE}"
	cat "_${INFILE}" | tail +2 | \
	    mysql --login-path=${USER} ${DBNAME} --local-infile -e \
		  "load data local infile '/dev/stdin' \
		   into table ${TABLENAME} \
		   fields terminated by '\t' \
		   optionally enclosed by '\"'; \
		   show count(*) warnings; \
		   show warnings;  "
    fi
else
    echo "${INFILE} not found, exiting"
    exit 1
fi



