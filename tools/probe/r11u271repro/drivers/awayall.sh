#!/bin/bash
# (r11u271: copied from r11u269repro/drivers)
# (r11u269: copied from r11u267repro/drivers)
# (r11u267: copied from r11u265repro/drivers)
# (r11u265: copied from r11u263repro/drivers)
# (r11u263: copied from r11u261repro/drivers)
# (r11u261: copied from r11u259repro/drivers)
# (r11u259: copied from r11u257repro/drivers)
# r11u261 awayall.sh <ptag> <ltag> <case-view>...: the order-blind AWAY census of case-views from the case.sh store
# ($S/g/<case-view>/{gold_*/golden.uhdm,<ptag>.uhdm,<ltag>.uhdm}): drivers/away.py (record multisets) when both
# sides pass stage 1, drivers/awaydump.py (uhdm-dump line multisets) otherwise. Needs drivers/env.sh sourced;
# a case-view naming a fenced test is refused before any file is opened.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
export SCMP=$STRICT_CMP
pt=$1; lt=$2; shift 2
for cv in "$@"; do
  echo "$cv" | grep -qwE "$FENCE_RE" && { echo "$cv FENCED-REFUSED"; continue; }
  w=$S/g/$cv; g=$(ls $w/gold_*/golden.uhdm 2>/dev/null | head -1)
  [ -s "$g" ] || { echo "$cv NO-GOLDEN"; continue; }
  if grep -q 'stage1\|NOT_EQUAL' $w/$pt.strict $w/$lt.strict 2>/dev/null && ! grep -q 'STRICT_' $w/$pt.strict; then
    echo "$cv dump $(python3 $D/awaydump.py $g $w/$pt.uhdm $w/$lt.uhdm | head -1)"
  elif tail -1 $w/$lt.strict | grep -q '^NOT_EQUAL'; then
    echo "$cv dump $(python3 $D/awaydump.py $g $w/$pt.uhdm $w/$lt.uhdm | head -1)"
  else
    mkdir -p $w/away_$lt; echo "$cv rec $(python3 $D/away.py $g $w/$pt.uhdm $w/$lt.uhdm $w/away_$lt | head -1)"
  fi
done
