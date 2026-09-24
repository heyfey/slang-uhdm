#!/usr/bin/env bash
# cmpgrid.sh <grid dir> <binA> <binB> : run the grid on both binaries, print a joined table
set -u
d=$(dirname "$(realpath "$0")"); g=$(realpath $1); t=$(basename $g)
"$d/grid.sh" $g $2 /tmp/r11u131_cg_A > /tmp/r11u131_cg_$t.A
"$d/grid.sh" $g $3 /tmp/r11u131_cg_B > /tmp/r11u131_cg_$t.B
join -t'|' <(sed 's/ /|/' /tmp/r11u131_cg_$t.A | sort) <(sed 's/ /|/' /tmp/r11u131_cg_$t.B | sort) | awk -F'|' '{m=($2==$3)?"  ":"**"; printf "%s %-40s A[%s]  B[%s]\n",m,$1,$2,$3}' | sed 's/r11u131repro__//;s/rc=0 //g;s/strict=//g;s/STRICT_//g'
