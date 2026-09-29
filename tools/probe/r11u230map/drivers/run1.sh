#!/bin/bash
# One strict run with record dumps (the variant comparator). args: corpus mode name golden ours
# env: SCMP (the frozen variant, drivers/strictcmp_x.cpp), DUMPS (output root)
[ -x "${SCMP:-}" ] || { echo "run1: SCMP not executable" >&2; exit 2; }
c=$1; m=$2; n=$3; g=$4; o=$5
D=$DUMPS/$c/$m; mkdir -p "$D"
[ -s "$D/$n.out" ] && grep -q '^rc=' "$D/$n.out" && exit 0
timeout 1800 "$SCMP" --max 50 --dump-a "$D/$n.a" --dump-b "$D/$n.b" "$g" "$o" > "$D/$n.out" 2>&1
echo "rc=$?" >> "$D/$n.out"
