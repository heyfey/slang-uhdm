#!/bin/bash
# grid3.sh <pristine> <law> <verified> <casedir>...: rc, uhdm-cmp lines, strict verdict and
# path-normalized dump distance to golden on all three binaries.
source $(dirname "$0")/env.sh || exit 1
P=$1; L=$2; V=$3; shift 3
for c in "$@"; do
  c=$(realpath "$c"); W=/tmp/v11u463_runs$c
  a=$($(dirname "$0")/runcase.sh "$P" pris "$c"); b=$($(dirname "$0")/runcase.sh "$L" law "$c"); v=$($(dirname "$0")/runcase.sh "$V" ver "$c")
  $UHDM_DUMP "$W/sl/slpp_all/surelog.uhdm" 2>/dev/null | sed 's/id:[0-9]*//' > "$W/g.nd"
  for t in pris law ver; do $UHDM_DUMP "$W/$t.uhdm" 2>/dev/null | sed 's/id:[0-9]*//' > "$W/$t.nd"; done
  d(){ diff "$W/g.nd" "$W/$1.nd" | grep -c '^[<>]'; }
  echo "${c#*/cases/} pris $(echo $a | cut -d' ' -f2-4) | law $(echo $b | cut -d' ' -f2-4) | ver $(echo $v | cut -d' ' -f2-4) | dist $(d pris) $(d law) $(d ver) | law=pris:$(cmp -s $W/pris.uhdm $W/law.uhdm && echo y || echo n) ver=pris:$(cmp -s $W/pris.uhdm $W/ver.uhdm && echo y || echo n) ver=law:$(cmp -s $W/law.uhdm $W/ver.uhdm && echo y || echo n)"
done
