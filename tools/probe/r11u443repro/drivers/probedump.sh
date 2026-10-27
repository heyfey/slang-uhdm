#!/bin/bash
# usage: probedump.sh <law probe dir> <control probe dir> <db name>: compares path-normalized dumps
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo "MISSING_DUMP"; exit 2; }
A=$1; B=$2; f=$3
n() { sed 1d | sed 's#/tmp/r11u443sw1#W#g; s#/tmp/intr11u441#W#g; s#/tmp/wt_r11u443/#R/#g; s#/home/heyfey/git-repos/slang-uhdm/#R/#g'; }
a=$($D $A/$f 2>/dev/null | n | md5sum); b=$($D $B/$f 2>/dev/null | n | md5sum)
[ "$a" = "$b" ] && echo "SAME $f" || echo "DIFF $f"
