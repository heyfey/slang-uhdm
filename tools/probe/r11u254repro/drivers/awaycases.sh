#!/bin/bash
# (r11u254: copied from r11u255repro/drivers)
# r11u255 awaycases.sh <case-view>... : the order-blind AWAY census (drivers/away.py) of grid case-views from the
# case.sh store ($S/g/<case>[_el]/{gold_*/golden.uhdm,P.uhdm,L.uhdm}). Needs drivers/env.sh sourced.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
export SCMP=$STRICT_CMP
for cv in "$@"; do
  w=$S/g/$cv; g=$(ls $w/gold_*/golden.uhdm 2>/dev/null | head -1)
  [ -s "$g" ] || { echo "$cv NO-GOLDEN"; continue; }
  mkdir -p $w/away; echo "$cv $(python3 $D/away.py $g $w/P.uhdm $w/L.uhdm $w/away | head -1)"
done
