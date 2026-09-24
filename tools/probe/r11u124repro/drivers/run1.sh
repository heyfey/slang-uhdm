#!/bin/bash
# args: corpus mode name golden ours — strictcmp record dumps for the analyzer
c=$1; m=$2; n=$3; g=$4; o=$5
D=/tmp/r11u124_ana/dumps/$c/$m; mkdir -p $D
timeout 900 /tmp/r11u124_bin/strictcmp --max 50 --dump-a "$D/$n.a" --dump-b "$D/$n.b" "$g" "$o" > "$D/$n.out" 2>&1
echo "rc=$?" >> "$D/$n.out"
