#!/bin/bash
# obrow.sh <wdA> <wdB> <corpus/mode/test>...: order-blind uhdm-dump distance (workdir paths and ids stripped, sorted)
# between two sweeps' databases of one row.  Fail-closed on $FENCED; a fenced row is refused unread.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "obrow.sh: source drivers/env.sh (FENCED)" >&2; exit 2; }
A=$1; B=$2; shift 2
TA=$(mktemp /tmp/r11u177_ob_a.XXXXXX); TB=$(mktemp /tmp/r11u177_ob_b.XXXXXX); trap "rm -f $TA $TB" EXIT
for r in "$@"; do
  t=$(basename $r); for f in $FENCED; do [ "$f" = "$t" ] && { echo "$r FENCED-REFUSED"; continue 2; }; done
  a=$(ls $A/$r-*/slang.uhdm 2>/dev/null | head -1); b=$(ls $B/$r-*/slang.uhdm 2>/dev/null | head -1)
  [ -s "$a" ] && [ -s "$b" ] || { echo "$r MISSING"; continue; }
  $UHDM_DUMP $a 2>/dev/null | sed -E "s#$A##g; s/id:[0-9]+//g" | sort > $TA
  $UHDM_DUMP $b 2>/dev/null | sed -E "s#$B##g; s/id:[0-9]+//g" | sort > $TB
  echo "$r ordered_bytes=$(cmp -s $a $b && echo same || echo differ) orderblind_lines=$(comm -3 $TA $TB | wc -l)"
done
