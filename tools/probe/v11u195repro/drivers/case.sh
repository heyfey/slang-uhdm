#!/bin/bash
# v11u195: judge one case dir like check_probe (golden cached per content md5 in /tmp/v11u195_gold).
# usage: case.sh <case dir> <outdir>; env SLANG_UHDM + extra env passed through
set -u
. "$(dirname "$(realpath "$0")")"/env.sh || exit 3
D=$(cd "$1" && pwd); O=$2
for f in $FENCED; do grep -qw "$f" <<< "$D" && { echo "fenced refused" >&2; exit 3; }; done
mkdir -p "$O"; rm -f "$O"/ours.uhdm "$O"/*.rec "$O"/*.dump "$O"/strict.txt "$O"/cmp.txt
SRC=dut.sv; [ -f "$D/args" ] && SRC=$(cat "$D/args")
K=$(cd "$D" && find . -type f ! -name LAW ! -name '*.txt' | sort | xargs md5sum | md5sum | cut -c1-16); G=/tmp/v11u195_gold/$K
if [ ! -s "$G/golden.uhdm" ]; then mkdir -p "$G/w"; ( cd "$D" && "$SURELOG" -parse -nobuiltin -nocache -sv $SRC -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"; fi
[ -s "$G/golden.uhdm" ] || { echo "SURELOG_FAIL"; exit 1; }
( cd "$D" && "$SLANG_UHDM" $SRC --single-unit --nobuiltin -o "$O/ours.uhdm" > "$O/slang.log" 2>&1; echo "rc=$?" >> "$O/slang.log" )
[ -s "$O/ours.uhdm" ] || { echo "SLANG_FAIL $(tail -1 $O/slang.log)"; exit 1; }
"$UHDM_CMP" "$G/golden.uhdm" "$O/ours.uhdm" > "$O/cmp.txt" 2>&1; crc=$?
"$SCMP" --max 50 --dump-a "$O/a.rec" --dump-b "$O/b.rec" "$G/golden.uhdm" "$O/ours.uhdm" > "$O/strict.txt" 2>&1; src=$?
echo "$G" > "$O/golden.path"
echo "cmp=$crc cmplines=$(wc -l < $O/cmp.txt) strict=$src $(grep -m1 -E '^(STRICT_|NOT_EQUAL)' $O/strict.txt) $(tail -1 $O/slang.log)"
