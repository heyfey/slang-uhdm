#!/bin/bash
# vaway404.sh <grid work dir> [glob] : golden-vs-ours normalised uhdm-dump diff line counts, pristine and law
# (and verified when v.uhdm exists); TOWARD / AWAY / SAME per case. Dumps strip ids and the work-dir path.
: ${UHDM_DUMP:?}
W=$1; G=${2:-*/*}
norm() { $UHDM_DUMP $1 2>/dev/null | sed 1d | sed -E 's/id:[0-9]+//g; s#/tmp/[^ ,]*/##g'; }
for w in $(cd $W && ls -d $G | sort); do
  d=$W/$w; [ -f $d/g/slpp_all/surelog.uhdm ] || continue
  norm $d/g/slpp_all/surelog.uhdm > $d/g.dump
  out="$w"
  for t in p l v; do
    [ -f $d/$t.uhdm ] || continue
    norm $d/$t.uhdm > $d/$t.dump
    eval n$t=$(diff $d/g.dump $d/$t.dump | grep -c '^[<>]')
    out="$out $t=$(eval echo \$n$t)"
  done
  if [ $nl -lt $np ]; then v=TOWARD; elif [ $nl -gt $np ]; then v=AWAY; else v=SAME; fi
  echo "$out $v"
done
