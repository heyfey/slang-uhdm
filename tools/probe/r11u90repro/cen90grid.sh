#!/usr/bin/env bash
# r11u90 CENSUS POSITIVE CONTROL — the same trace, the same binary, on the
# GRID, so the corpus zeros are readings and not a dead instrument.
# usage: GRID=<dir> cen90grid.sh <binary>
# Columns: NET = net listing sites reached, STR = those whose declaration
# carries a drive/charge strength, DROP = LAW A's net answer, PORT = the u12
# boundary (a strength declaration that ALSO names a port, net kept);
# CELL/CSTR/CDROP = the same three for the net-decl-assign CELL site;
# DLY = the cont_assign delays LAW B respells as a reference.
set -u
BIN=${1:?binary}; GRID=${GRID:?set GRID}
printf '%-20s %5s %4s %4s %4s %5s %4s %5s %4s\n' \
       arm NET STR DROP PORT CELL CSTR CDROP DLY
for a in $(ls -d $GRID/*/ | xargs -n1 basename | sort -V); do
  d=$GRID/$a; [ -f "$d/dut.sv" ] || continue
  err=$( cd $d && R11U90_CELLDBG=1 $BIN dut.sv --single-unit --nobuiltin \
           -o /dev/null 2>&1 >/dev/null )
  net=$(printf '%s\n' "$err" | grep -c '^R11U90NET'; true)
  str=$(printf '%s\n' "$err" | grep -c '^R11U90NET .* str=1'; true)
  drp=$(printf '%s\n' "$err" | grep -c '^R11U90NET .* drop=1'; true)
  prt=$(printf '%s\n' "$err" | grep -c '^R11U90NET .* str=1 port=1'; true)
  cel=$(printf '%s\n' "$err" | grep -c '^R11U90CELL'; true)
  cst=$(printf '%s\n' "$err" | grep -c '^R11U90CELL .* str=1'; true)
  cdr=$(printf '%s\n' "$err" | grep -c '^R11U90CELL .* drop=1'; true)
  dly=$(printf '%s\n' "$err" | grep -c '^R11U90DLY'; true)
  [ "$str$drp$prt$cst$cdr$dly" = "000000" ] && continue
  printf '%-20s %5s %4s %4s %4s %5s %4s %5s %4s\n' \
    "$a" "$net" "$str" "$drp" "$prt" "$cel" "$cst" "$cdr" "$dly"
done
