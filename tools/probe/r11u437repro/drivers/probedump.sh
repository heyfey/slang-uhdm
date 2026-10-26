#!/bin/bash
# probedump.sh <name.uhdm> : path-normalized dump compare law vs control
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo NODUMP; exit 2; }
f=$1
n(){ "$D" "$1" 2>/dev/null | sed 1d | sed -E 's#/tmp/wt_r11u437/#/R/#g; s#/home/heyfey/git-repos/slang-uhdm/#/R/#g; s#/tmp/(r11u437_LW|intr11u435)/#/W/#g'; }
if cmp -s <(n /tmp/r11u437_LW/probe/$f) <(n /tmp/intr11u435/probe/$f); then echo "SAME $f"; else echo "MOVER $f"; fi
