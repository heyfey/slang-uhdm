#!/bin/bash
# v11u196 case judge: case.sh <case dir> <binary tag: pris|law|...> [EL=1]; mirrors scripts/check_probe.py's command lines
. "$(dirname "$0")/env.sh"
D=$(cd "$1" && pwd); B=$V196_BIN/$2
for f in $FENCED; do echo "$D" | grep -qw -- "$f" && { echo "fenced path refused"; exit 3; }; done
ek=""; sx=""; ox=""; [ "${EL:-0}" = 1 ] && { ek="_el"; sx="-elabuhdm"; ox="--elabuhdm"; }
K=$(cd "$D" && find . -type f ! -name LAW | sort | xargs md5sum | md5sum | cut -c1-16)$ek
G=/tmp/v11u196_gold/$K; O=/tmp/v11u196_run/$(echo "$D" | sed "s#$V196_REPO/tools/probe/v11u196repro/cases/##; s#/#_#g")$ek/$2${ENVTAG:-}
mkdir -p $O; rm -f $O/*
if [ ! -s "$G/golden.uhdm" ]; then rm -rf "$G/w"; mkdir -p "$G/w"; ( cd "$D" && "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv $sx -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"; fi
[ -s "$G/golden.uhdm" ] || { echo "$1 SURELOG_FAIL"; exit 1; }
( cd "$D" && "$B" dut.sv --single-unit --nobuiltin $ox -o "$O/ours.uhdm" > "$O/slang.log" 2>&1; echo "rc=$?" >> "$O/slang.log" )
rc=$(tail -1 "$O/slang.log")
[ -s "$O/ours.uhdm" ] || { echo "$1 $2 SLANG_FAIL $rc"; exit 1; }
"$UHDM_CMP" "$G/golden.uhdm" "$O/ours.uhdm" > "$O/cmp.txt" 2>&1
"$STRICT_CMP" --max 50 --dump-a "$O/a.rec" --dump-b "$O/b.rec" "$G/golden.uhdm" "$O/ours.uhdm" > "$O/strict.txt" 2>&1
"$UHDM_DUMP" "$G/golden.uhdm" 2>/dev/null | sed "s#$G[^ ]*##g; s#$D/##g" > "$O/g.dump"; "$UHDM_DUMP" "$O/ours.uhdm" 2>/dev/null | sed "s#$D/##g" > "$O/o.dump"
echo "$1 $2 $rc cmplines=$(wc -l < $O/cmp.txt) $(grep -m1 -E '^(STRICT_|NOT_EQUAL)' $O/strict.txt | cut -c1-150) md5=$(md5sum < $O/ours.uhdm | cut -c1-8)"
