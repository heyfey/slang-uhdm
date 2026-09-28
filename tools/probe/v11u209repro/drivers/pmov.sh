#!/bin/bash
# v11u209: pmov.sh <wdA> <wdB> <rootA> <rootB> -- the probe databases of two sweeps whose uhdm-dump differs once the two
# worktree roots and workdirs are normalised (probe databases carry the worktree path, so bytes cannot be compared).
# pmov.sh <wdA> <wdB> <rootA> <rootB>: probe dbs whose uhdm-dump (paths normalised) differ
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh"
A=$1; B=$2; RA=$3; RB=$4
one(){ f=$1; a=$($UHDM_DUMP $A/probe/$f 2>&1 | sed -e "s#$RA#ROOT#g" -e "s#$A#WD#g" | tail -n +2 | md5sum); b=$($UHDM_DUMP $B/probe/$f 2>&1 | sed -e "s#$RB#ROOT#g" -e "s#$B#WD#g" | tail -n +2 | md5sum); [ "$a" = "$b" ] || echo "${f%.uhdm}"; }
export -f one; export A B RA RB UHDM_DUMP
ls $A/probe | grep '\.uhdm$' | xargs -P 3 -I{} bash -c 'one {}'
