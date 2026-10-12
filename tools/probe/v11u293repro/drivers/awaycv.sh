#!/bin/bash
# (v11u293: copied from r11u293repro/drivers)
# (r11u293: copied from r11u291repro/drivers)
# (r11u291: copied from r11u289repro/drivers)
# (r11u287: copied from r11u285repro/drivers)
# (r11u285: copied from r11u283repro/drivers)
# (r11u283: copied from r11u281repro/drivers)
# r11u275 awaycv.sh <ptag> <ltag> <case-view rel>...: the order-blind (away.py) and chain-keyed (awaychain.py) away
# census of each case-view case.sh left under $S/g/<rel> (golden, <ptag>.uhdm, <ltag>.uhdm). Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] && [ -n "$S" ] && [ -n "$B" ] || { echo "awaycv.sh: source drivers/env.sh" >&2; exit 2; }
D=$(cd "$(dirname "$0")" && pwd); pt=$1; lt=$2; shift 2
export SCMP=$B/uhdm-strictcmp SCX=$B/strictcmp_x
for t in "$SCMP" "$SCX"; do [ -x "$t" ] || { echo "awaycv.sh: tool not executable: $t" >&2; exit 2; }; done
for rel in "$@"; do
  for n in $FENCED; do echo "$rel" | grep -qw "$n" && { echo "awaycv.sh: fenced refused" >&2; exit 2; }; done
  w=$S/g/$rel; g=$(ls $w/gold_*/golden.uhdm 2>/dev/null | head -1)
  [ -s "$g" ] && [ -s $w/$pt.uhdm ] && [ -s $w/$lt.uhdm ] || { echo "$rel MISSING"; continue; }
  mkdir -p $w/away
  echo "$rel $(python3 $D/away.py $g $w/$pt.uhdm $w/$lt.uhdm $w/away) | $(python3 $D/awaychain.py $g $w/$pt.uhdm $w/$lt.uhdm | head -1)"
done
