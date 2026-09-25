#!/bin/bash
# pdump.sh <name> <wdA> <wdB>: path-normalised uhdm-dump comparison of one probe db
source /tmp/v11u147_env.sh
n=$1; a=$2/probe/$n.uhdm; b=$3/probe/$n.uhdm
da=$($UHDM_DUMP $a 2>&1 | sed -E 's#/tmp/wt_v11u147(pris)?/##g; s#/tmp/v11u147_wd[A-Za-z0-9]+/##g; s#id:[0-9]+##g' | md5sum | cut -c1-12)
db=$($UHDM_DUMP $b 2>&1 | sed -E 's#/tmp/wt_v11u147(pris)?/##g; s#/tmp/v11u147_wd[A-Za-z0-9]+/##g; s#id:[0-9]+##g' | md5sum | cut -c1-12)
[ "$da" = "$db" ] && echo "SAME $n" || echo "MOVER $n"
