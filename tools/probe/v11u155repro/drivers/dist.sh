#!/bin/bash
# dist <golden> <ours> : order-blind dump distance (lines in the symmetric difference of sorted dumps, workdir-normalised)
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
n() { $D "$1" 2>/dev/null | sed -E 's#/tmp/[^ ,:]*/##g; s/^[ |\\_]*//' | sort; }
comm -3 <(n $1) <(n $2) | wc -l
