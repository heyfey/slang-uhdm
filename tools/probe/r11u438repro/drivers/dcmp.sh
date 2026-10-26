#!/bin/bash
# dcmp.sh <rel>: path-normalized dump compare of law vs control database
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || exit 2
n(){ $D $1 2>/dev/null | sed -E 's/, id:[0-9]+//; s#/tmp/wt_r11u438/#/R/#g; s#/home/heyfey/git-repos/slang-uhdm/#/R/#g; s#/tmp/(r11u438_L|intr11u436)/#/W/#g'; }
if cmp -s <(n /tmp/r11u438_L/$1) <(n /tmp/intr11u436/$1); then echo "same $1"; else echo "MOVER $1"; fi
