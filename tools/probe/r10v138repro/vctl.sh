#!/usr/bin/env bash
# r10v138 — must-stay control arms: golden + pristine + FIXED, both views,
# scored cell-by-cell over the whole cen138 census (not just return_stmt).
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CEN=/tmp/wt_v138/tools/probe/r10uvm138repro/cen138.py
PRIS=/tmp/v138_bin/pris.bin; FIX=/tmp/v138_bin/fix.bin
F=$(readlink -f "$1"); D=$(readlink -f "$2"); mkdir -p "$D"; B=$(basename "$F")
cp "$F" "$D/"
for h in "$(dirname "$F")"/*.svh; do [ -f "$h" ] && cp "$h" "$D/"; done
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv "$B" >sl.log 2>&1 </dev/null ); grc=$?
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
( cd "$D" && "$PRIS" "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); orc=$?
( cd "$D" && "$FIX"  "$B"            -o x.uhdm  >x.log  2>&1 </dev/null ); xrc=$?
( cd "$D" && "$PRIS" "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); oerc=$?
( cd "$D" && "$FIX"  "$B" --elabuhdm -o xe.uhdm >xe.log 2>&1 </dev/null ); xerc=$?
bd=SAME; cmp -s "$D/o.uhdm" "$D/x.uhdm" 2>/dev/null || bd=MOVED
be=SAME; cmp -s "$D/oe.uhdm" "$D/xe.uhdm" 2>/dev/null || be=MOVED
echo "$B  slrc=$grc rc=$orc/$xrc erc=$oerc/$xerc  defbytes=$bd elabbytes=$be"
if [ "$bd" = MOVED ] || [ "$be" = MOVED ]; then
  for t in g o x oe xe; do [ -f "$D/$t.uhdm" ] && "$DUMP" "$D/$t.uhdm" 2>/dev/null | python3 "$CEN" - | sort > "$D/$t.cen"; done
  [ -f "$D/g.cen" ] && python3 /tmp/v138_arm/vscore.py "$D/g.cen" "$D/o.cen" "$D/x.cen" | tail -1
fi
