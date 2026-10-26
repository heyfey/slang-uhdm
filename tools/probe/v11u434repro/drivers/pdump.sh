#!/bin/bash
# pdump.sh <name>: path-normalized dump compare of one probe database, law sweep vs the master's control
n=$1; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
nz(){ sed 's|/tmp/wt_v11u434/|ROOT/|g; s|/home/heyfey/git-repos/slang-uhdm/|ROOT/|g; s|/tmp/v11u434sw1/|WD/|g; s|/tmp/intr11u432/|WD/|g'; }
a=$($D /tmp/v11u434sw1/probe/$n 2>/dev/null | nz | md5sum); b=$($D /tmp/intr11u432/probe/$n 2>/dev/null | nz | md5sum)
[ "$a" = "$b" ] && echo "SAME $n" || echo "DIFF $n"
