#!/bin/bash
# grid.sh <bin> <tag>: every case dir under cases/ -> one line (rc, uhdm-cmp lines, strict verdict, md5)
D=$(cd $(dirname "$0")/.. && pwd)
cd $D/cases && bash $D/drivers/runcase.sh "$1" "$2" $(ls -d */* | sort)
