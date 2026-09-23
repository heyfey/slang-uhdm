#!/bin/bash
# shapes117.sh <out-root> <tagA> <tagB> [param] — per arm, the SHAPE LISTER's
# package/module param_assign lines for IMPL, golden vs each tag, spans dropped.
OUT=${1:?}; shift; P=${PARAM:-IMPL}
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
H=$(dirname "$0")
for w in "$OUT"/*/; do a=$(basename "$w"); [ -f "$w/gold.uhdm" ] || continue
  for t in gold "$@"; do [ -f "$w/$t.uhdm" ] || continue
    [ -s "$w/$t.dump" ] && [ "$w/$t.dump" -nt "$w/$t.uhdm" ] || $D "$w/$t.uhdm" > "$w/$t.dump" 2>&1
    python3 "$H/pkgshape117.py" "$w/$t.dump" "$P" | sed 's/, line:[0-9:]*, endln:[0-9:]*//' > "$w/$t.shape"
  done
  for t in "$@"; do
    if cmp -s "$w/gold.shape" "$w/$t.shape"; then echo "$a $t SAME $(tr '\n' ';' < "$w/gold.shape" | cut -c1-120)"
    else echo "$a $t DIFF"; diff "$w/gold.shape" "$w/$t.shape" | grep '^[<>]' | sed 's/^/    /'; fi
  done
done
