#!/usr/bin/env bash
# r11u69 CENSUS — every ELABORATED cont_assign that lives inside a GENERATE
# scope, golden shape vs ours, over a whole sweep workdir.
#
# Golden-vs-golden calibration is the caller's job (run it with OURS=golden).
# usage: r11u69_census.sh <workdir/mode-dir> <out.tsv> [OURS=golden]
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
MD=${1:?mode dir}; OUT=${2:?out}; SIDE=${3:-ours}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
# A uhdm-dump on the biggest goldens can outrun any budget; a TIMEOUT row
# is RECORDED, never silently dropped, so a census zero cannot hide one.
TMO=${TMO:-45}
: > $OUT
for d in $MD/*/; do
  n=$(basename $d)
  [ -f "$d/cmds.txt" ] || continue
  g=$(sed -n 's/.*golden cache hit \([^)]*\)).*/\1/p' $d/cmds.txt | head -1)
  [ -n "$g" ] || continue
  [ -f "$g/golden.uhdm" ] || continue
  if [ "$SIDE" = golden ]; then o=$g/golden.uhdm; else o=$d/slang.uhdm; fi
  [ -f "$o" ] || continue
  timeout $TMO $DUMP $g/golden.uhdm > /tmp/r11u69_cg.$$ 2>/dev/null \
    || { printf '%s\tTIMEOUT-G\n' "$n" >> $OUT; continue; }
  timeout $TMO $DUMP $o > /tmp/r11u69_co.$$ 2>/dev/null \
    || { printf '%s\tTIMEOUT-O\n' "$n" >> $OUT; continue; }
  python3 $HERE/shapes69.py /tmp/r11u69_cg.$$ elab 2>/dev/null \
    | awk -F'\t' -v n="$n" '$1 != "" {print n"\tG\t"$0}' >> $OUT
  python3 $HERE/shapes69.py /tmp/r11u69_co.$$ elab 2>/dev/null \
    | awk -F'\t' -v n="$n" '$1 != "" {print n"\tO\t"$0}' >> $OUT
done
rm -f /tmp/r11u69_cg.$$ /tmp/r11u69_co.$$
wc -l $OUT
