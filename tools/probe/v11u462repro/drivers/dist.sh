#!/bin/bash
# dist.sh <case rel path under cases/> : dump-diff line count golden vs pris and golden vs law (ids stripped)
source /tmp/v11u462_env.sh
W=/tmp/v11u462_runs/tmp/wt_v11u462/tools/probe/$1
n(){ $UHDM_DUMP "$1" 2>/dev/null | tail -n +2 | sed -E 's/, id:[0-9]+//g; s/id:[0-9]+//g'; }
n $W/sl/slpp_all/surelog.uhdm > $W/g.dump; n $W/pris.uhdm > $W/p.dump; n $W/law.uhdm > $W/l.dump
echo "$1 golden-vs-pris=$(diff $W/g.dump $W/p.dump | grep -c '^[<>]') golden-vs-law=$(diff $W/g.dump $W/l.dump | grep -c '^[<>]') pris-vs-law=$(diff $W/p.dump $W/l.dump | grep -c '^[<>]')"
