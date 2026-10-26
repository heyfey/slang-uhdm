#!/bin/bash
# pdump.sh <name>: path-normalized dump compare of one probe database, law vs control
n=$1; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
a=$($D /tmp/r11u434sw4/probe/$n 2>/dev/null | sed 's|/tmp/wt_r11u434/|ROOT/|g; s|/home/heyfey/git-repos/slang-uhdm/|ROOT/|g; s|/tmp/r11u434sw4/|WD/|g; s|/tmp/intr11u432/|WD/|g' | md5sum)
b=$($D /tmp/intr11u432/probe/$n 2>/dev/null | sed 's|/tmp/wt_r11u434/|ROOT/|g; s|/home/heyfey/git-repos/slang-uhdm/|ROOT/|g; s|/tmp/r11u434sw4/|WD/|g; s|/tmp/intr11u432/|WD/|g' | md5sum)
[ "$a" = "$b" ] && echo "SAME $n" || echo "DIFF $n"
