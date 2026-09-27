#!/bin/bash
# r11u183: which r11u183 laws FIRE on each case of cases/ (R11U183_TRACE with the final law binary), one line per
# case: <case> <law>:<firings> ...   usage: casefire.sh [binary] > evidence/case_firings.tsv
B=${1:-/tmp/r11u183_bin/slang-uhdm.lawJ}; HERE=$(cd "$(dirname "$0")" && pwd); T=/tmp/r11u183_casefire; rm -rf $T; mkdir -p $T
for d in $(find $HERE/../cases -name dut.sv -printf '%h\n' | sort); do
  r=$(basename $(dirname $d))/$(basename $d); mkdir -p $T/$r/tr
  ( cd $d && R11U183_TRACE=$T/$r/tr $B dut.sv --single-unit --nobuiltin -o $T/$r/o.uhdm > /dev/null 2>&1 < /dev/null )
  printf '%s\t%s\n' "$r" "$(cat $T/$r/tr/* 2>/dev/null | grep -v '^OUT ' | sort | uniq -c | awk '{printf "%s:%s ", $2, $1}')"
done
