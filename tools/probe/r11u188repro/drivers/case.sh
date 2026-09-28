#!/bin/bash
# r11u188: judge one case dir (dut.sv) the way scripts/check_probe.py does, keeping everything.
# usage: case.sh <case dir> [outdir]   env: R188_BIN, SLANG_UHDM (the binary under test, absolute),
# TOP (the root file, default dut.sv; a case dir holding dut.v and no dut.sv takes dut.v: Surelog's lexer mode keys on the extension)
# writes <outdir>/{golden.uhdm,ours.uhdm,strict.txt,a.rec,b.rec,g.dump,o.dump}; golden cached per text md5 in
# ${R188_GOLD:-/tmp/r11u188_gold}/<md5>/. Refuses the four fenced names.
set -u
. "$(dirname "$0")/env.sh" || exit 3
D=$(cd "$1" && pwd); O=${2:-/tmp/r11u188_run/$(echo "$D" | md5sum | cut -c1-12)}
r188_fenced "$D" && { echo "case.sh: fenced path refused" >&2; exit 3; }
TOP=${TOP:-dut.sv}; [ ! -f "$D/dut.sv" ] && [ -f "$D/dut.v" ] && TOP=dut.v
mkdir -p "$O"; rm -f "$O"/ours.uhdm "$O"/*.rec "$O"/*.dump "$O"/strict.txt
K=$( (echo "$D"; cat "$D"/*.sv "$D"/*.svh "$D"/*.v 2>/dev/null) | md5sum | cut -c1-16); G=${R188_GOLD:-/tmp/r11u188_gold}/$K
if [ ! -s "$G/golden.uhdm" ]; then mkdir -p "$G/w"; ( cd "$D" && "$SURELOG" -parse -nobuiltin -nocache -sv $TOP -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"; fi
[ -s "$G/golden.uhdm" ] || { echo "SURELOG_FAIL"; exit 1; }
cp "$G/golden.uhdm" "$O/golden.uhdm"
( cd "$D" && "$SLANG_UHDM" $TOP --single-unit --nobuiltin -o "$O/ours.uhdm" > "$O/slang.log" 2>&1; echo "rc=$?" >> "$O/slang.log" )
[ -s "$O/ours.uhdm" ] || { echo "SLANG_FAIL $(tail -1 $O/slang.log)"; exit 1; }
"$UHDM_CMP" "$O/golden.uhdm" "$O/ours.uhdm" > "$O/cmp.txt" 2>&1; crc=$?
"$SCMP" --max 50 --dump-a "$O/a.rec" --dump-b "$O/b.rec" "$O/golden.uhdm" "$O/ours.uhdm" > "$O/strict.txt" 2>&1; src=$?
"$UHDM_DUMP" "$O/golden.uhdm" 2>/dev/null | sed "s#$G[^ ]*##g" > "$O/g.dump"; "$UHDM_DUMP" "$O/ours.uhdm" 2>/dev/null > "$O/o.dump"
echo "cmp=$crc cmplines=$(wc -l < $O/cmp.txt) strict=$src $(grep -m1 -E '^(STRICT_|NOT_EQUAL)' $O/strict.txt) out=$O"
