#!/usr/bin/env bash
# r10v155 — THE WIDE BOUNDARY GATE, THREE BINARIES IN ONE TRAVERSAL.
# Descended verbatim from r10uvm155repro/bound155.sh (same guards: file list on
# fd 3, children </dev/null, PROCESSED asserted against LISTED, scratch keyed on
# the RELATIVE path, no language flag, a PRODUCED counter that convicts a
# green-on-nothing run).  The only change is a THIRD binary column so the
# as-shipped patch and the verifier's fixed binary are scored against the SAME
# pristine traversal.  MEASUREMENT ONLY; uhdm-cmp judges the cells.
#   usage: PRIS=.. PATCHED=.. FIXED=.. bound3v155.sh <dir-of-arms> <outdir>
set -u
SRC=$(readlink -f "${1:?arms dir}"); OUT=$(readlink -f "${2:?outdir}"); mkdir -p "$OUT"
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}; FIXED=${FIXED:?}
find "$SRC" \( -name '*.sv' -o -name '*.v' \) | sort > "$OUT/LISTED"
LISTED=$(wc -l < "$OUT/LISTED"); PROCESSED=0; MOVP=0; MOVF=0; RCD=0; PRODUCED=0
: > "$OUT/MOVERS"
while read -r f <&3; do
  rel=${f#$SRC/}; key=$(echo "$rel" | tr '/' '_')
  W="$OUT/$key.d"; mkdir -p "$W"; cp "$f" "$W/" 2>/dev/null
  for h in "$(dirname "$f")"/*.svh "$(dirname "$f")"/*.vh; do [ -f "$h" ] && cp "$h" "$W/"; done
  b=$(basename "$f")
  ( cd "$W" && "$PRIS"    "$b"            -o o.uhdm  >o.log  2>&1 </dev/null ); prc=$?
  ( cd "$W" && "$PATCHED" "$b"            -o q.uhdm  >q.log  2>&1 </dev/null ); qrc=$?
  ( cd "$W" && "$FIXED"   "$b"            -o r.uhdm  >r.log  2>&1 </dev/null ); rrc=$?
  ( cd "$W" && "$PRIS"    "$b" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); perc=$?
  ( cd "$W" && "$PATCHED" "$b" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); qerc=$?
  ( cd "$W" && "$FIXED"   "$b" --elabuhdm -o re.uhdm >re.log 2>&1 </dev/null ); rerc=$?
  [ -f "$W/o.uhdm" ] && PRODUCED=$((PRODUCED+1))
  if [ "$prc" != "$qrc" ] || [ "$prc" != "$rrc" ]; then RCD=$((RCD+1)); fi
  if [ "$perc" != "$qerc" ] || [ "$perc" != "$rerc" ]; then RCD=$((RCD+1)); fi
  pd=SAME; pe=SAME; fd=SAME; fe=SAME
  if [ -f "$W/o.uhdm" ] || [ -f "$W/q.uhdm" ]; then cmp -s "$W/o.uhdm" "$W/q.uhdm" 2>/dev/null || pd=MOVED; fi
  if [ -f "$W/oe.uhdm" ] || [ -f "$W/qe.uhdm" ]; then cmp -s "$W/oe.uhdm" "$W/qe.uhdm" 2>/dev/null || pe=MOVED; fi
  if [ -f "$W/o.uhdm" ] || [ -f "$W/r.uhdm" ]; then cmp -s "$W/o.uhdm" "$W/r.uhdm" 2>/dev/null || fd=MOVED; fi
  if [ -f "$W/oe.uhdm" ] || [ -f "$W/re.uhdm" ]; then cmp -s "$W/oe.uhdm" "$W/re.uhdm" 2>/dev/null || fe=MOVED; fi
  mp=no; mf=no
  if [ "$pd" = MOVED ] || [ "$pe" = MOVED ]; then MOVP=$((MOVP+1)); mp=yes; fi
  if [ "$fd" = MOVED ] || [ "$fe" = MOVED ]; then MOVF=$((MOVF+1)); mf=yes; fi
  if [ "$mp" = yes ] || [ "$mf" = yes ]; then
    printf "%s\tPAT(def=%s,elab=%s)\tFIX(def=%s,elab=%s)\trc=%s/%s/%s,%s/%s/%s\n" \
      "$rel" "$pd" "$pe" "$fd" "$fe" "$prc" "$qrc" "$rrc" "$perc" "$qerc" "$rerc" >> "$OUT/MOVERS"
  fi
  PROCESSED=$((PROCESSED+1))
  rm -f "$W"/*.uhdm
done 3< "$OUT/LISTED"
echo "LISTED=$LISTED PROCESSED=$PROCESSED PRODUCED_DBS=$PRODUCED MOVED_ARMS_PATCHED=$MOVP MOVED_ARMS_FIXED=$MOVF RC_DIFFS=$RCD"
[ "$LISTED" = "$PROCESSED" ] || { echo "FATAL: the gate did not reach every arm"; exit 3; }
