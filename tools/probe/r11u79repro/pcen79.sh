#!/usr/bin/env bash
# r11u79 CENSUS POSITIVE CONTROL.  A census zero proves nothing unless the
# instrument is shown to fire, so the SAME trace `pkgcen79.py` reads off the
# corpus is read off the grid arms here, where the moved entries are known by
# name.  usage: GRID=<dir> pcen79.sh <patched-binary>
set -u
BIN=${1:?binary}
GRID=${GRID:?set GRID}
printf '%-20s %6s %6s %6s %6s\n' arm list listMOVED var varMOVED
for d0 in $GRID/*/; do
  d=${d0%/}; a=$(basename $d)
  [ -f "$d/dut.sv" ] || continue
  err=$( cd $d && R11U79_CELLDBG=1 $BIN dut.sv --single-unit --nobuiltin \
           -o /dev/null 2>&1 >/dev/null )
  l=$(printf '%s\n' "$err" | grep -c '^R11U79LIST'; true)
  lm=$(printf '%s\n' "$err" | grep '^R11U79LIST' | grep -c 'MOVED'; true)
  v=$(printf '%s\n' "$err" | grep -c '^R11U79VAR'; true)
  vm=$(printf '%s\n' "$err" | grep '^R11U79VAR' | grep -c 'MOVED'; true)
  printf '%-20s %6s %6s %6s %6s\n' $a $l $lm $v $vm
done
