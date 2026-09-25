#!/bin/bash
# obdist.sh <golden.uhdm> <a.uhdm> <b.uhdm> : order-blind uhdm-dump distance to golden of a and b
# (lines only in golden + lines only in ours, ids and paths normalised, LC_ALL=C sorted).
norm(){ $UHDM_DUMP "$1" 2>/dev/null | sed -E 's/id:[0-9]+//g; s|/[^ ,)]*/||g' | LC_ALL=C sort; }
g=$(mktemp /tmp/r11u172_ob.XXXX); a=$(mktemp /tmp/r11u172_ob.XXXX); b=$(mktemp /tmp/r11u172_ob.XXXX)
norm "$1" > $g; norm "$2" > $a; norm "$3" > $b
da=$(LC_ALL=C comm -3 $g $a | wc -l); db=$(LC_ALL=C comm -3 $g $b | wc -l)
echo "a=$da b=$db"; rm -f $g $a $b
