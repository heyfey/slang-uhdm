#!/bin/bash
# run1.sh <tag> corpus mode name golden ours — strictcmp record dumps for the analyzer
t=$1; c=$2; m=$3; n=$4; g=$5; o=$6
D=/tmp/r11u131_ana/$t/$c/$m; mkdir -p $D
timeout 900 /tmp/r11u131_bin/strictcmp --max 50 --dump-a "$D/$n.a" --dump-b "$D/$n.b" "$g" "$o" > "$D/$n.out" 2>&1
echo "rc=$?" >> "$D/$n.out"
