#!/bin/bash
# dist.sh <casedir>...: path-normalized uhdm-dump diff line counts golden-vs-pristine and golden-vs-law
source /tmp/wt_v11u460/tools/probe/v11u460repro/drivers/env.sh || exit 1
for c in "$@"; do
  c=$(realpath "$c"); W=/tmp/v11u460_runs$c
  n(){ $UHDM_DUMP "$1" 2>/dev/null | sed -E 's/, id:[0-9]+//g; s/id:[0-9]+//g' | sed "s#$c/##g; s#$W/[^ ,]*##g"; }
  n $W/sl/slpp_all/surelog.uhdm > $W/g.dump; n $W/pris.uhdm > $W/p.dump; n $W/law.uhdm > $W/l.dump
  echo "${c#*/cases/} dist pris=$(diff $W/g.dump $W/p.dump | grep -c '^[<>]') law=$(diff $W/g.dump $W/l.dump | grep -c '^[<>]') glines=$(wc -l < $W/g.dump)"
done
