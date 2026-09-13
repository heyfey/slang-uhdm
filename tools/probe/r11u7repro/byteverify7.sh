#!/bin/bash
# r11u7 — name every DATABASE whose bytes move between two verify_golden
# workdirs, by test/mode.  usage: byteverify7.sh <wd-a> <wd-b>
# SELFCHECK=1 also reports how many databases exist on both sides (a run that
# compares nothing prints MOVERS 0 and means nothing).
set -u
A=$(readlink -f "${1:?workdir a}"); B=$(readlink -f "${2:?workdir b}")
tot=0; mov=0; both=0
while IFS= read -r f; do
  rel=${f#$A/}
  g="$B/$rel"
  tot=$((tot+1))
  [ -f "$g" ] || { echo "ONLY-A $rel"; continue; }
  both=$((both+1))
  ma=$(md5sum < "$f" | cut -d' ' -f1)
  mb=$(md5sum < "$g" | cut -d' ' -f1)
  [ "$ma" = "$mb" ] || { echo "MOVER $rel"; mov=$((mov+1)); }
done < <(find "$A" -name slang.uhdm | sort)
echo "SELFCHECK both=$both of a=$tot"
echo "MOVERS $mov/$both"
