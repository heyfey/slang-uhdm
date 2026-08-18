#!/usr/bin/env bash
# r10uvm95 — THE NAMED PINS.  md5 of the DATABASE for every name the standing
# brief pins, patched vs pristine, per mode, printed side by side.  A name that
# matches no directory prints UNKNOWN-NAME and is COUNTED.
#   usage: pins89.sh <patched wd> <pristine wd>
set -u
A=${1:?patched wd}; B=${2:?pristine wd}
NAMES=${NAMES:-"InterfaceModPort BlackParrotComplex YosysOldOr SVSwitch YosysVerx"}
unk=0; bad=0; ok=0
printf "%-20s %-9s %-14s %-14s %s\n" NAME MODE PRISTINE PATCHED VERDICT
for n in $NAMES; do
  seen=0
  for m in default testflags; do
    for d in "$A/$m/$n"-*/; do
      [ -d "$d" ] || continue
      rel=${d#$A/}
      [ -f "$A/$rel/slang.uhdm" ] && [ -f "$B/$rel/slang.uhdm" ] || continue
      seen=1
      pa=$(md5sum "$A/$rel/slang.uhdm" | cut -c1-12)
      pb=$(md5sum "$B/$rel/slang.uhdm" | cut -c1-12)
      v=SAME; [ "$pa" = "$pb" ] || { v=MOVED; bad=$((bad+1)); }
      [ "$v" = SAME ] && ok=$((ok+1))
      printf "%-20s %-9s %-14s %-14s %s\n" "$n" "$m" "$pb" "$pa" "$v"
    done
  done
  [ "$seen" -eq 0 ] && { printf "%-20s %-9s %-14s %-14s %s\n" "$n" - - - UNKNOWN-NAME; unk=$((unk+1)); }
done
echo "---- pins SAME=$ok MOVED=$bad UNKNOWN-NAME=$unk"
[ "$ok" -gt 0 ] || { echo "REFUSING TO REPORT: 0 pins measured"; exit 4; }
