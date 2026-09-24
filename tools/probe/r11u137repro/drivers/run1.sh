#!/bin/bash
# run1.sh corpus mode name golden ours  (env DUMPS) -> strictcmp_x --max 60 with dumps
c=$1; m=$2; n=$3; g=$4; o=$5
D=$DUMPS/$c/$m; mkdir -p "$D"
[ -s "$D/$n.out" ] && grep -q '^rc=' "$D/$n.out" && exit 0
timeout 600 /tmp/r11u137_bin/strictcmp_x --max 60 --dump-a "$D/$n.a" --dump-b "$D/$n.b" "$g" "$o" > "$D/$n.out" 2>&1
echo "rc=$?" >> "$D/$n.out"
