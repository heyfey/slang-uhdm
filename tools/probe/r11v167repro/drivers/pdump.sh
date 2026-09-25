#!/bin/bash
# (scratch-specific: compares the law sweep /tmp/v11u167_swL and the pristine sweep /tmp/v11u167_swP probe databases by normalised uhdm-dump; the two sweeps ran from worktrees of different path length)
f=$1; a=$($UHDM_DUMP /tmp/v11u167_swL/probe/$f 2>/dev/null | sed 1d | sed 's#/tmp/wt_v11u167pris/#R/#g; s#/tmp/wt_v11u167/#R/#g' | md5sum); b=$($UHDM_DUMP /tmp/v11u167_swP/probe/$f 2>/dev/null | sed 1d | sed 's#/tmp/wt_v11u167pris/#R/#g; s#/tmp/wt_v11u167/#R/#g' | md5sum); [ "$a" = "$b" ] || echo ${f%.uhdm}
