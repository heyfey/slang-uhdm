#!/bin/bash
# r11u6/heads.sh <sweep-workdir/<mode>> [name-prefixes...]
# One head per row, read from the databases the SWEEP already built (never
# re-runs the exporter, so what is scored is exactly what the judge scored).
# LHS is ALWAYS golden.  Prints CMPLINES (stdout+stderr both) and the head.
WD=${1:?workdir/mode}; shift
CMP=${CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
for n in "$@"; do
  d=$(ls -d "$WD/$n"-* 2>/dev/null | head -1)
  if [ -z "$d" ]; then echo "$n SKIP-NODIR"; continue; fi
  o="$d/slang.uhdm"
  g=$(grep -o 'golden cache hit [^)]*' "$d/cmds.txt" | awk '{print $4}')
  g=$(ls "$g"/*.uhdm 2>/dev/null | head -1)
  if [ ! -f "$o" ] || [ -z "$g" ]; then echo "$n SKIP-NOFILE o=$o g=$g"; continue; fi
  "$CMP" "$g" "$o" > /tmp/.r11u6h_$$.out 2> /tmp/.r11u6h_$$.err
  nl=$(( $(wc -l < /tmp/.r11u6h_$$.out) + $(wc -l < /tmp/.r11u6h_$$.err) ))
  hd=$(grep -c '^LHS:' /tmp/.r11u6h_$$.err; true)
  obj=$(grep -A2 '^LHS:' /tmp/.r11u6h_$$.err | sed -n '3p')
  printf '%-26s cmplines=%-5s heads=%-3s %s\n' "$n" "$nl" "$hd" "$obj"
done
rm -f /tmp/.r11u6h_$$.out /tmp/.r11u6h_$$.err
