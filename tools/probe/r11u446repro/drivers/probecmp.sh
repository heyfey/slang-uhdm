#!/bin/bash
f=$1; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
a=$($D /tmp/r11u446sw/probe/$f 2>/dev/null | tail -n +2 | sed 's|/tmp/wt_r11u446/|ROOT/|g; s|/tmp/r11u446sw/probe|WD|g; s/, id:[0-9]*//' | md5sum | cut -c1-12)
b=$($D /tmp/intr11u444/probe/$f 2>/dev/null | tail -n +2 | sed 's|/home/heyfey/git-repos/slang-uhdm/|ROOT/|g; s|/tmp/intr11u444/probe|WD|g; s/, id:[0-9]*//' | md5sum | cut -c1-12)
[ "$a" = "$b" ] || echo "MOVER $f"
