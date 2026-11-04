#!/bin/bash
# cmpdiff.sh <casedir-under-runs> <tag>: uhdm-cmp LHS/RHS blocks diffed with ids stripped
source /tmp/v11u482_env.sh
W=$1; T=$2
$UHDM_CMP $W/sl/slpp_all/surelog.uhdm $W/$T.uhdm > /tmp/v11u482_gen/c.cmp 2>&1
r=$(grep -n '^RHS' /tmp/v11u482_gen/c.cmp | head -1 | cut -d: -f1)
sed -n 1,4p /tmp/v11u482_gen/c.cmp | cut -c1-150
sed -n "$r,$((r+3))p" /tmp/v11u482_gen/c.cmp | cut -c1-150
sed -n "2,$((r-1))p" /tmp/v11u482_gen/c.cmp | sed -E 's/id:[0-9]+//' > /tmp/v11u482_gen/l.txt
sed -n "$((r+1)),\$p" /tmp/v11u482_gen/c.cmp | sed -E 's/id:[0-9]+//' > /tmp/v11u482_gen/r.txt
diff /tmp/v11u482_gen/l.txt /tmp/v11u482_gen/r.txt | head -${3:-30} | cut -c1-150
