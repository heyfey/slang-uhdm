#!/usr/bin/env bash
# r10uvm134 — A-PRIORI MOVER PREDICTION, BY NAME, from the PRISTINE databases
# of a verify_golden workdir.  MEASUREMENT ONLY; the official uhdm-cmp judges.
#
#   CEN=<ct134cen> pred134.sh <workdir> [<outdir>]
#
# A database can move under § foreachLoopListStopsAtFirstSelect134 only if its
# pristine dump holds a foreach_stmt whose Variable() slot is
#   * a hier_path whose written text contains a '[' (the loop list carried an
#     index select before a dot — the shape the law re-reads), or
#   * a ref_var / hier_path under a `this.`-rooted selected loop list.
# The census column VFULL carries that text verbatim, so the predicate is a
# pure grep over the census rows.  Every rc is recorded; a database whose
# census crashes is reported, never silently counted as "cannot move".
set -u
CEN=${CEN:?set CEN=<ct134cen binary>}
WD=${1:?workdir}
OUT=${2:-/tmp/r10uvm134_pred}
mkdir -p "$OUT"
: > "$OUT/rows.txt"; : > "$OUT/rcs.txt"
n=0; bad=0; hit=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    f="$d/slang.uhdm"; [ -f "$f" ] || continue
    rel=$(basename "$d"); n=$((n+1))
    "$CEN" "$f" > "$OUT/tmp.cen" 2>"$OUT/tmp.err" </dev/null; rc=$?
    echo "$mode $rel rc=$rc" >> "$OUT/rcs.txt"
    [ "$rc" -ne 0 ] && { bad=$((bad+1)); echo "CENSUS-RC $mode $rel rc=$rc"; }
    c=$(grep -c 'VKIND=hier_path|VNAME=-|VFULL=[^|]*\[' "$OUT/tmp.cen"); true
    t=$(grep -c '^VKIND=' "$OUT/tmp.cen"); true
    if [ "${c:-0}" -gt 0 ]; then
      hit=$((hit+1)); echo "MOVER-CANDIDATE $mode $rel selpaths=$c foreach=$t" >> "$OUT/rows.txt"
    fi
  done
done
echo "-- databases=$n census-rc-nonzero=$bad mover-candidates=$hit"
sort "$OUT/rows.txt"
