#!/bin/bash
# pdump1.sh <name> [<other name>]: path-normalized dump compare of a probe database, law sweep vs control
n=$1; m=${2:-$1}; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
N='s|/tmp/wt_r11u436/|ROOT/|g; s|/home/heyfey/git-repos/slang-uhdm/|ROOT/|g; s|/tmp/r11u436sw1/|WD/|g; s|/tmp/intr11u434/|WD/|g'
a=$($D /tmp/r11u436sw1/probe/$n 2>/dev/null | sed "$N" | tail -n +2 | md5sum)
b=$($D /tmp/intr11u434/probe/$m 2>/dev/null | sed "$N" | tail -n +2 | md5sum)
[ "$a" = "$b" ] && echo "SAME $n" || echo "DIFF $n"
