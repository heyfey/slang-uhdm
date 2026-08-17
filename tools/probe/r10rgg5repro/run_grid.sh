#!/usr/bin/env bash
# r10rgg5/run_grid.sh -- golden (real Surelog) + each slang-uhdm binary, per
# cell, printing EVERY `get_next_n` call's ARGUMENT constant (size + value).
#
#   usage: [BASE=<bin>] [PAT=<bin>] ./run_grid.sh <outdir> <cell>...
#
# GUARDS
#   * the DUT is copied from Surelog's own tree at run time, so a cell can
#     never drift from the file that carries the head.
#   * a side that produces NO database, or a dump with NO get_next_n call at
#     all, prints NO-DATABASE / NO-CALL and is COUNTED.  A comparator that
#     reaches nothing must never read as agreement.
#   * argconst.py exits 3 on a dump with zero calls (its own guard).
set -u
OUT=${1:?outdir}; shift
here=$(cd "$(dirname "$0")" && pwd)
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
DUT=$HOME/git-repos/Surelog/third_party/tests/rggen/rggen-sv-rtl/rggen_or_reducer.sv
[ -f "$DUT" ] || { echo "FATAL: no DUT at $DUT"; exit 3; }
[ -x "$SL" ] || { echo "FATAL: no surelog at $SL"; exit 3; }
bad=0
for c in "$@"; do
  d=$here/$c
  [ -d "$d" ] || { echo "== $c  NO-CELL"; bad=$((bad+1)); continue; }
  w=$OUT/$c; mkdir -p "$w" || exit 1
  cp "$d"/top_$c.sv "$DUT" "$w"/
  ( cd "$w" && "$SL" -parse -nopython -d uhdm -top top_$c rggen_or_reducer.sv top_$c.sv \
      > gold.dump 2> gold.err )
  if [ ! -s "$w/gold.dump" ]; then echo "== $c GOLD NO-DATABASE"; bad=$((bad+1));
  else python3 "$here/argconst.py" "$w/gold.dump" "$c GOLD" || { bad=$((bad+1)); echo "== $c GOLD NO-CALL"; }
  fi
  for tag in BASE PAT; do
    b=$(eval echo "\${$tag:-}")
    [ -z "$b" ] && continue
    ( cd "$w" && "$b" --single-unit --top top_$c rggen_or_reducer.sv top_$c.sv \
        -o $tag.uhdm > $tag.log 2>&1 )
    if [ ! -s "$w/$tag.uhdm" ]; then echo "== $c $tag NO-DATABASE"; bad=$((bad+1)); continue; fi
    "$DUMP" "$w/$tag.uhdm" > "$w/$tag.dump" 2>&1
    python3 "$here/argconst.py" "$w/$tag.dump" "$c $tag" || { bad=$((bad+1)); echo "== $c $tag NO-CALL"; }
  done
done
echo "PROBLEMS=$bad"
