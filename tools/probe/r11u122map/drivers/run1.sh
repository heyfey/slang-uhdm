#!/bin/bash
# args: corpus mode name golden ours
c=$1; m=$2; n=$3; g=$4; o=$5
D=/tmp/r11u122_dumps/$c/$m; mkdir -p $D
[ -s "$D/$n.out" ] && grep -q '^rc=' "$D/$n.out" && exit 0
timeout 600 /tmp/r11u122_bin/uhdm-strictcmp --max 50 --dump-a "$D/$n.a" --dump-b "$D/$n.b" "$g" "$o" > "$D/$n.out" 2>&1
echo "rc=$?" >> "$D/$n.out"
