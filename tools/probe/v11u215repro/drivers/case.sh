#!/bin/bash
# v11u215: judge one case dir (dut.sv or args) against pinned Surelog v1.87; ELAB=1 for the -elabuhdm form.
# usage: case.sh <case dir> <outdir>   env: SLANG_UHDM (absolute). Fence fail-closed.
set -u
. "$(dirname "${BASH_SOURCE[0]:-$0}")/env.sh" || exit 3
D=$(cd "$1" && pwd); O=$2
for f in $FENCED; do grep -qw "$f" <<< "$D" && { echo "case.sh: fenced path refused" >&2; exit 3; }; done
mkdir -p "$O"; rm -f "$O"/ours.uhdm "$O"/*.rec "$O"/*.dump "$O"/strict.txt "$O"/cmp.txt
SRC=dut.sv; [ -f "$D/args" ] && SRC=$(cat "$D/args"); [ ! -f "$D/args" ] && [ -f "$D/files" ] && SRC=$(cat "$D/files" | tr "\n" " ")
K=$(cd "$D" && find . -type f ! -name LAW | sort | xargs md5sum | md5sum | cut -c1-16); G=/tmp/v11u215_gold/$K${ELAB:+_elab}
SLE=; OUE=; [ -n "${ELAB:-}" ] && { SLE=-elabuhdm; OUE=--elabuhdm; }
if [ ! -s "$G/golden.uhdm" ]; then mkdir -p "$G/w"; ( cd "$D" && "$SURELOG" -parse $SLE -nobuiltin -nocache -sv $SRC -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"; fi
[ -s "$G/golden.uhdm" ] || { echo "SURELOG_FAIL"; exit 1; }
cp "$G/golden.uhdm" "$O/golden.uhdm"
( cd "$D" && "$SLANG_UHDM" $SRC --single-unit --nobuiltin $OUE -o "$O/ours.uhdm" > "$O/slang.log" 2>&1; echo "rc=$?" >> "$O/slang.log" )
[ -s "$O/ours.uhdm" ] || { echo "SLANG_FAIL $(tail -1 $O/slang.log)"; exit 1; }
"$UHDM_CMP" "$O/golden.uhdm" "$O/ours.uhdm" > "$O/cmp.txt" 2>&1; crc=$?
"$SCMP" --max 50 --dump-a "$O/a.rec" --dump-b "$O/b.rec" "$O/golden.uhdm" "$O/ours.uhdm" > "$O/strict.txt" 2>&1; src=$?
"$UHDM_DUMP" "$O/golden.uhdm" 2>/dev/null > "$O/g.dump"; "$UHDM_DUMP" "$O/ours.uhdm" 2>/dev/null > "$O/o.dump"
echo "cmp=$crc strict=$src $(grep -m1 -E '^(STRICT_|NOT_EQUAL)' $O/strict.txt) $(tail -1 $O/slang.log)"
