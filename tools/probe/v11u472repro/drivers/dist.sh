#!/bin/bash
# dist.sh <casedir>...: for runs of runcase.sh tags pris and law: class-listing distance
# (clsall diff lines vs golden) and path-normalized uhdm-dump distance vs golden.
UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
CA=/tmp/v11u472_scratch/clsall
for v in UHDM_DUMP CA; do [ -x "${!v}" ] || { echo "missing $v"; exit 1; }; done
n() { $UHDM_DUMP "$1" 2>&1 | tail -n +2 | sed -E 's/, id:[0-9]+//; s#file:[^,]*/##'; }
for c in "$@"; do
  c=$(realpath "$c"); W=/tmp/v11u472_runs$c; G=$W/sl/slpp_all/surelog.uhdm
  out="${c#*/cases/}"
  for t in pris law; do
    cl=$(diff <($CA $G) <($CA $W/$t.uhdm) | grep -c '^[<>]')
    dd=$(diff <(n $G) <(n $W/$t.uhdm) | grep -c '^[<>]')
    out="$out $t:cls=$cl,dump=$dd"
  done
  echo "$out"
done
