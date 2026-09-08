#!/bin/bash
# r10uvm212 — the PROTECTED-DATABASE md5 check.  MEASUREMENT ONLY.
# Prints the 12-hex md5 prefix of each protected row's `slang.uhdm` under the
# PATCHED and the PRISTINE workdir, in both modes, and says SAME or MOVED.
#
#   usage: protdb212.sh <patched-workdir> <pristine-workdir>
#
# GUARD: a row whose database is missing on either side prints NOFILE and is
# COUNTED — a check that reaches nothing must never read as perfection.
set -u
A=${1:?patched workdir}
B=${2:?pristine workdir}
NAMES="InterfaceModPort BlackParrotComplex YosysOldOr SVSwitch YosysVerx
YosysBigSimReed YosysOldOpen ApbSlave ClassExtends Earlgrey_0_1"
seen=0; miss=0; moved=0
for n in $NAMES; do
  for m in default testflags; do
    a=$(ls "$A/$m/$n"-*/slang.uhdm 2>/dev/null | head -1)
    b=$(ls "$B/$m/$n"-*/slang.uhdm 2>/dev/null | head -1)
    if [ -z "$a" ] || [ -z "$b" ]; then
      printf "  %-20s %-9s NOFILE\n" "$n" "$m"; miss=$((miss+1)); continue
    fi
    ha=$(md5sum "$a" | cut -c1-12); hb=$(md5sum "$b" | cut -c1-12)
    v=SAME; [ "$ha" = "$hb" ] || { v=MOVED; moved=$((moved+1)); }
    printf "  %-20s %-9s patched=%s pristine=%s %s\n" "$n" "$m" "$ha" "$hb" "$v"
    seen=$((seen+1))
  done
done
echo "-- compared=$seen NOFILE=$miss MOVED=$moved"
[ "$seen" -gt 0 ] || { echo "GATE FAIL: compared nothing"; exit 4; }
