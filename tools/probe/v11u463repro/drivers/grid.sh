#!/bin/bash
# grid.sh <pristine bin> <law bin> <casedir>...: per case rc, uhdm-cmp lines,
# strict verdict and the path-normalized dump distance to golden on both binaries.
source $(dirname "$0")/env.sh || exit 1
P=$1; L=$2; shift 2
for c in "$@"; do
  c=$(realpath "$c"); W=/tmp/v11u463_runs$c
  $(dirname "$0")/runcase.sh "$P" pris "$c" > /tmp/v11u463_g1.txt
  $(dirname "$0")/runcase.sh "$L" law "$c" > /tmp/v11u463_g2.txt
  $UHDM_DUMP "$W/sl/slpp_all/surelog.uhdm" 2>/dev/null | sed 's/id:[0-9]*//' > "$W/g.nd"
  for t in pris law; do $UHDM_DUMP "$W/$t.uhdm" 2>/dev/null | sed 's/id:[0-9]*//' > "$W/$t.nd"; done
  dp=$(diff "$W/g.nd" "$W/pris.nd" | grep -c '^[<>]'); dl=$(diff "$W/g.nd" "$W/law.nd" | grep -c '^[<>]')
  echo "$(cat /tmp/v11u463_g1.txt | cut -d' ' -f1-4 | sed 's/rc=/pris rc=/') | $(cut -d' ' -f2- /tmp/v11u463_g2.txt | sed 's/^/law /') | dist $dp -> $dl"
done
