#!/bin/bash
# v11u303 trigscan.sh <probe tree> <workroot>: runs the FIX binary ($B/fix) under R11U303_TRACE over every case dir
# (dut.sv / dut.v, args honoured) of an earlier repro tree, default view, to select byte-control cases by FIRING
# (laws, refinement abstentions and the laws' own abstentions); prints one line per firing case dir.
# Fail-closed on $FENCED: the path list is filtered BEFORE any file is opened.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] && [ -n "$B" ] || { echo "trigscan.sh: source drivers/env.sh" >&2; exit 2; }
[ -x "$B/fix" ] || { echo "trigscan.sh: fix binary missing" >&2; exit 2; }
T=$1; W=$2; FR="$(echo $FENCED | tr ' ' '|')"
mkdir -p $W/tr $W/o
find $T -name dut.sv -o -name dut.v | grep -vwE "$FR" | sed 's#/dut\.s\?v$##' | sort -u > $W/dirs.txt
run() { c=$1; k=$(echo $c | md5sum | cut -c1-12); SRC=dut.sv; SV=; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args)
  mkdir -p $W/tr/$k; (cd $c && R11U303_TRACE=$W/tr/$k timeout 120 $B/fix $SRC --single-unit --nobuiltin -o $W/o/$k.uhdm >/dev/null 2>&1)
  rm -f $W/o/$k.uhdm; if ls $W/tr/$k/*.303 >/dev/null 2>&1; then echo "$c $(cat $W/tr/$k/*.303 | grep -v '^OUT ' | cut -d' ' -f1 | sort | uniq -c | awk '{printf "%s:%s ", $2, $1}')"; fi; rm -rf $W/tr/$k; }
export -f run; export W B
cat $W/dirs.txt | xargs -P 3 -I{} bash -c 'run {}'
