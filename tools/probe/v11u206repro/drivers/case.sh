#!/bin/bash
# v11u206: judge one case dir (dut.sv) as check_probe.py does. usage: case.sh <bin> <casedir> <outdir> [ENV=VAL...]
set -u; . /tmp/v11u206_drv/env.sh || exit 3
BIN=$1; D=$(cd "$2" && pwd); O=$3; shift 3
for f in $FENCED; do grep -qw "$f" <<< "$D" && { echo "fenced path refused" >&2; exit 3; }; done
mkdir -p "$O"; rm -f "$O"/ours.uhdm "$O"/*.rec "$O"/strict.txt "$O"/cmp.txt
K=$(cd "$D" && find . -type f -name '*.sv*' | sort | xargs md5sum | md5sum | cut -c1-16); G=/tmp/v11u206_gold/$K
if [ ! -s "$G/golden.uhdm" ]; then mkdir -p "$G/w"; ( cd "$D" && "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"; fi
[ -s "$G/golden.uhdm" ] || { echo "SURELOG_FAIL"; exit 1; }
ln -sf "$G/golden.uhdm" "$O/golden.uhdm"
( cd "$D" && env "$@" "$BIN" dut.sv --single-unit --nobuiltin -o "$O/ours.uhdm" > "$O/slang.log" 2>&1; echo "rc=$?" >> "$O/slang.log" )
rc=$(tail -1 $O/slang.log)
[ -s "$O/ours.uhdm" ] || { echo "SLANG_FAIL $rc"; exit 1; }
"$UHDM_CMP" "$O/golden.uhdm" "$O/ours.uhdm" > "$O/cmp.txt" 2>&1; crc=$?
"$SCMP" --max 0 "$O/golden.uhdm" "$O/ours.uhdm" > "$O/strictv.txt" 2>&1; src=$?
"$SCMP" --max 30 --dump-a "$O/a.rec" --dump-b "$O/b.rec" "$O/golden.uhdm" "$O/ours.uhdm" > "$O/strict.txt" 2>&1
if [ $src = 1 ]; then v=stage1; elif grep -q '^STRICT_EQUAL' $O/strictv.txt; then v=equal; else v="differ:$(grep -m1 '^STRICT_NOTEQUAL' $O/strictv.txt | cut -d' ' -f2)($(grep -m1 -o 'objects_differing=[0-9]*' $O/strictv.txt | cut -d= -f2))"; fi
echo "$rc cmp=$crc $v md5=$(md5sum < $O/ours.uhdm | cut -c1-10)"
