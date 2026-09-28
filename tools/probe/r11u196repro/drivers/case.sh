#!/bin/bash
# r11u196: judge one case dir the way scripts/check_probe.py does, keeping everything.
# usage: case.sh <case dir> [outdir]   env: R196_BIN, SLANG_UHDM (the binary under test, absolute);
# EL=1 judges the elaborated view (Surelog -elabuhdm, ours --elabuhdm).  An `args` file (or `files`, one per line)
# lists the root files of the unit (r11u190's convention); else dut.sv (dut.v when no dut.sv).
# writes <outdir>/{golden.uhdm,ours.uhdm,cmp.txt,strict.txt,a.rec,b.rec,g.dump,o.dump,slang.log}; golden cached per
# the case's text (every file but LAW) in ${R196_GOLD:-/tmp/r11u196_gold}/<md5><_el>/. Refuses the four fenced names.
set -u
. "$(dirname "$0")/env.sh" || exit 3
D=$(cd "$1" && pwd); O=${2:-/tmp/r11u196_run/$(echo "$D" | md5sum | cut -c1-12)}
r196_fenced "$D" && { echo "case.sh: fenced path refused" >&2; exit 3; }
SRC=dut.sv; [ ! -f "$D/dut.sv" ] && [ -f "$D/dut.v" ] && SRC=dut.v
[ -f "$D/args" ] && SRC=$(cat "$D/args"); [ ! -f "$D/args" ] && [ -f "$D/files" ] && SRC=$(tr "\n" " " < "$D/files")
ek=""; sx=""; ox=""; [ "${EL:-0}" = 1 ] && { ek="_el"; sx="-elabuhdm"; ox="--elabuhdm"; }
mkdir -p "$O"; rm -f "$O"/ours.uhdm "$O"/*.rec "$O"/*.dump "$O"/strict.txt "$O"/cmp.txt
K=$(cd "$D" && find . -type f ! -name LAW | sort | xargs md5sum | md5sum | cut -c1-16)$ek; G=${R196_GOLD:-/tmp/r11u196_gold}/$K
if [ ! -s "$G/golden.uhdm" ]; then rm -rf "$G/w"; mkdir -p "$G/w"; ( cd "$D" && "$SURELOG" -parse -nobuiltin -nocache -sv $SRC $sx -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"; fi
[ -s "$G/golden.uhdm" ] || { echo "SURELOG_FAIL"; exit 1; }
cp "$G/golden.uhdm" "$O/golden.uhdm"
( cd "$D" && "$SLANG_UHDM" $SRC --single-unit --nobuiltin $ox -o "$O/ours.uhdm" > "$O/slang.log" 2>&1; echo "rc=$?" >> "$O/slang.log" )
rc=$(tail -1 "$O/slang.log")
[ -s "$O/ours.uhdm" ] || { echo "SLANG_FAIL $rc"; exit 1; }
"$UHDM_CMP" "$O/golden.uhdm" "$O/ours.uhdm" > "$O/cmp.txt" 2>&1; crc=$?
"$SCMP" --max 50 --dump-a "$O/a.rec" --dump-b "$O/b.rec" "$O/golden.uhdm" "$O/ours.uhdm" > "$O/strict.txt" 2>&1; src=$?
"$UHDM_DUMP" "$O/golden.uhdm" 2>/dev/null | sed "s#$G[^ ]*##g; s#$D/##g" > "$O/g.dump"; "$UHDM_DUMP" "$O/ours.uhdm" 2>/dev/null | sed "s#$D/##g" > "$O/o.dump"
echo "$rc cmp=$crc cmplines=$(wc -l < $O/cmp.txt) $(grep -m1 -E '^(STRICT_|NOT_EQUAL)' $O/strict.txt) out=$O"
