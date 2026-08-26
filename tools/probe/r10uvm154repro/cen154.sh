#!/usr/bin/env bash
# r10uvm154 — corpus-wide enum_const census driver.  MEASUREMENT ONLY.
#
#   usage: CT154CEN=/abs/ct154cen ./cen154.sh <sweep-workdir> <out.tsv>
#
# Walks every <mode>/<test>-<hash>/ cell of a verify_golden.py workdir, resolves
# the GOLDEN database (in-workdir slpp_all/surelog.uhdm, or the golden cache dir
# named by cmds.txt when the sweep took a cache hit — a cache hit leaves NO
# surelog.uhdm in the workdir and a naive walk would silently census only the
# handful of misses), and runs the census reader on golden and ours.
# LHS is ALWAYS golden; RHS is ALWAYS ours.  Output columns:
#   <mode> <test> <side> <EC|...row>
set -u
CT=${CT154CEN:?set CT154CEN}
WD=${1:?workdir}; OUT=${2:?out}
: > "$OUT"
n=0; ng=0
for d in "$WD"/*/*/; do
  [ -f "$d/cmds.txt" ] || continue
  mode=$(basename "$(dirname "$d")")
  test=$(basename "$d"); test=${test%-*}
  g=""
  if [ -f "$d/slpp_all/surelog.uhdm" ]; then g="$d/slpp_all/surelog.uhdm"
  elif [ -f "$d/slpp_unit/surelog.uhdm" ]; then g="$d/slpp_unit/surelog.uhdm"
  else
    c=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' "$d/cmds.txt")
    [ -n "$c" ] && [ -f "$c/golden.uhdm" ] && g="$c/golden.uhdm"
  fi
  [ -n "$g" ] || continue
  ng=$((ng+1))
  "$CT" "$g" 2>/dev/null | sed "s#^#$mode\t$test\tG\t#" >> "$OUT"
  if [ -f "$d/slang.uhdm" ]; then
    "$CT" "$d/slang.uhdm" 2>/dev/null | sed "s#^#$mode\t$test\tO\t#" >> "$OUT"
    n=$((n+1))
  fi
done
echo "CELLS_WITH_GOLDEN=$ng CELLS_WITH_OURS=$n rows=$(wc -l < "$OUT")"
