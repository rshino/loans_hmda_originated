#!/usr/bin/bash
# load_hmda_lar_v01.sh <file>
# e.g., load_hmda_lar_v01.sh /tmp/2022_hmda_lar_filter.csv

DBNAME=loans
TABLENAME=hmda_lar
if [ "$1" = "-n" ] ; then
   unset LOADFILE;shift 1
   else LOADFILE='Y'
fi
if [ $# -eq 0 ]; then echo "usage: $0 [-n] <file>"; exit 1;fi
export INFILE="${1}"
if [ -f "${INFILE}" ]
then
    #EXT=$(echo "${INFILE}" | sed 's/^.*\([.][^.]*\)$/\1/')
    #echo ${EXT}
    #OUTFILE=$(basename "${INFILE}" "${EXT}").tsv
    OUTFILE=${INFILE}
else
    echo "${INFILE} not found, exiting"
    exit 1
fi


if [ "${LOADFILE}" = "Y" ]
then
    echo "LOADING ${OUTFILE}"
    head -1 "${INFILE}" | sed -e 's/,/\n/g'|awk '{printf("%0.3d %s\n",NR,$0)}'
    cat "${OUTFILE}" | tail +2 | mysql --login-path=${USER} ${DBNAME} --local-infile -e \
    "load data local infile '/dev/stdin' \
    into table ${TABLENAME} \
    fields terminated by ',' \
    optionally enclosed by '\"'; \
    show count(*) warnings; \
    show warnings;  "
fi


