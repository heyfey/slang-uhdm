#!/bin/bash
# v11u210: compare the probe databases of two tests/sweep.sh runs made from two worktrees. The databases embed the
# case source path (which carries the worktree name), so each pair is compared on its uhdm-dump with the worktree root
# replaced by a fixed token. usage: probecmp.sh <sweepA> <wtA> <sweepB> <wtB>  (probe cases only: no corpus source)
A=$1; WA=$2; B=$3; WB=$4; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
one() { f=$1; a=$($D $A/probe/$f 2>/dev/null | sed "s#$WA#@WT#g; s#$A#@SW#g" | md5sum); b=$($D $B/probe/$f 2>/dev/null | sed "s#$WB#@WT#g; s#$B#@SW#g" | md5sum); [ "$a" = "$b" ] || echo "PROBE_MOVER $f"; }
export -f one; export A WA B WB D
(cd $A/probe && ls *.uhdm) | xargs -P3 -I{} bash -c 'one {}'
