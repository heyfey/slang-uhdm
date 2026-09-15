#!/bin/bash
# r11u47 — head size (cmp lines) + first RHS object for a sweep workdir.
W=$1
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
for d in "$W"/*/*/; do
  [ -f "$d/slang.uhdm" ] || continue
  G=$(grep -o 'golden cache hit [^)]*' "$d/cmds.txt" | awk '{print $4}')
  [ -n "$G" ] || continue
  GU="$G/golden.uhdm"
  [ -f "$GU" ] || continue
  n=$(basename "$d"); m=$(basename "$(dirname "$d")")
  "$CMP" "$GU" "$d/slang.uhdm" > /tmp/r11u47_hc.$$ 2>&1
  rc=$?
  lines=$(wc -l < /tmp/r11u47_hc.$$)
  heads=$(grep -c '^LHS:' /tmp/r11u47_hc.$$; true)
  first=$(sed -n '3p' /tmp/r11u47_hc.$$)
  echo "$m/${n%-*} rc=$rc lines=$lines heads=$heads LHS0='$first'"
done
rm -f /tmp/r11u47_hc.$$
