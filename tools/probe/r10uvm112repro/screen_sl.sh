#!/bin/bash
# Corpus-wide A-PRIORI mover screen for § classTdCloneSpecOverridesOwnArgs112.
# Reads PRISTINE databases only.  Two stages: cheap alias grep, then pred112.
set -u
D=$HOME/git-repos/UHDM/build/bin/uhdm-dump
P=/tmp/wt_r10uvm112/tools/probe/r10uvm112repro/pred112.py
ROOT=${ROOT:?}; OUT=${OUT:?}
: > "$OUT"
find "$ROOT" -name slang.uhdm | sort | while read -r f; do
  rel=${f#$ROOT/}
  T=/tmp/r10uvm112_scratch/scr_sl.dump
  $D "$f" 2>/dev/null > "$T" </dev/null
  n=$(grep -c 'vpiTypedefAlias' "$T"; true)
  [ "$n" -gt 0 ] || continue
  out=$(timeout 1800 python3 "$P" "$T" 2>&1 | grep -v 'cells=0 refs=0')
  [ -n "$out" ] || continue
  echo "### $rel" >> "$OUT"
  echo "$out" | sed "s#$T#$rel#" >> "$OUT"
done
echo "SCREEN-DONE"
