#!/bin/bash
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
f=$1
a=$($D /tmp/r11u442_LW/probe/$f 2>/dev/null | sed 's|/tmp/r11u442_LW|WD|g; s|/tmp/intr11u440|WD|g; s|/tmp/wt_r11u442/|ROOT/|g; s|/home/heyfey/git-repos/slang-uhdm/|ROOT/|g' | md5sum | cut -c1-12)
b=$($D /tmp/intr11u440/probe/$f 2>/dev/null | sed 's|/tmp/r11u442_LW|WD|g; s|/tmp/intr11u440|WD|g; s|/tmp/wt_r11u442/|ROOT/|g; s|/home/heyfey/git-repos/slang-uhdm/|ROOT/|g' | md5sum | cut -c1-12)
[ "$a" = "$b" ] && echo "same $f" || echo "DIFF $f"
