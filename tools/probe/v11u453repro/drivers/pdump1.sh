#!/bin/bash
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || exit 2
f=$1
if ! cmp -s <($D /tmp/v11u453swp/probe/$f 2>/dev/null | sed "s|/tmp/v11u453swp|WD|g; s|/tmp/wt_v11u453/|ROOT/|g; s/id:[0-9]*//g" | tail -n +2) <($D /tmp/intr11u450/probe/$f 2>/dev/null | sed "s|/tmp/intr11u450|WD|g; s|/home/heyfey/git-repos/slang-uhdm/|ROOT/|g; s/id:[0-9]*//g" | tail -n +2); then echo "DUMPMOVER $f"; fi
