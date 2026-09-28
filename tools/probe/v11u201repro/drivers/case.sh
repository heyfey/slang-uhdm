#!/bin/bash
# v11u201: judge one case dir (dut.sv) as scripts/check_probe.py does. usage: case.sh <case dir> <outdir>
# env SLANG_UHDM (absolute), ELAB=1 for the -elabuhdm form on both sides, XENV="VAR=1 ..." extra env for ours.
set -u
. "$(cd "$(dirname "$0")" && pwd)/env.sh" || exit 3
D=$(cd "$1" && pwd) || exit 3; [ -f "$D/dut.sv" ] || { echo "case.sh: no dut.sv" >&2; exit 3; }; O=$2
for f in $FENCED; do grep -qw "$f" <<< "$D" && { echo "case.sh: fenced path refused" >&2; exit 3; }; done
mkdir -p "$O"; rm -f "$O"/ours.uhdm "$O"/*.rec "$O"/*.dump "$O"/strict.txt "$O"/cmp.txt
K=$(cd "$D" && find . -type f ! -name LAW | sort | xargs md5sum | md5sum | cut -c1-16); G=/tmp/v11u201_gold/$K${ELAB:+_elab}
SLE=; OUE=; [ -n "${ELAB:-}" ] && { SLE=-elabuhdm; OUE=--elabuhdm; }
if [ ! -s "$G/golden.uhdm" ]; then mkdir -p "$G/w"; ( cd "$D" && timeout 300 "$SURELOG" -parse $SLE -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"; fi
[ -s "$G/golden.uhdm" ] || { echo "SURELOG_FAIL"; exit 1; }
( cd "$D" && env ${XENV:-} timeout 300 "$SLANG_UHDM" dut.sv --single-unit --nobuiltin $OUE -o "$O/ours.uhdm" > "$O/slang.log" 2>&1; echo "rc=$?" >> "$O/slang.log" )
[ -s "$O/ours.uhdm" ] || { echo "SLANG_FAIL $(tail -n 1 $O/slang.log)"; exit 1; }
"$UHDM_CMP" "$G/golden.uhdm" "$O/ours.uhdm" > "$O/cmp.txt" 2>&1; crc=$?
"$SCMP" --max 50 --dump-a "$O/a.rec" --dump-b "$O/b.rec" "$G/golden.uhdm" "$O/ours.uhdm" > "$O/strict.txt" 2>&1; src=$?
echo "$G" > "$O/golden.path"
echo "cmp=$crc strict=$src $(grep -m1 -E '^(STRICT_|NOT_EQUAL)' $O/strict.txt) $(grep -o 'objects_differing=[0-9]*' $O/strict.txt | head -1) $(tail -n 1 $O/slang.log)"
