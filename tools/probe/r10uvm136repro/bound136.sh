#!/usr/bin/env bash
# r10uvm136 — THE BOUNDARY GATE, run from a COPY of the probe directory so no
# path filter can hide an arm.  It compiles EVERY .sv in the copy (top level AND
# subdirectories), in BOTH views, with the pristine and the patched binary, and
# fails LOUDLY on any rc difference or any cmp-line difference that the law does
# not name.  Every child gets </dev/null; the file list is read on fd 3;
# PROCESSED is asserted against LISTED; scratch is keyed on the RELATIVE path.
#   usage: PRIS=.. PATCHED=.. bound136.sh <dir-of-arms> <outdir>
set -u
SRC=$(readlink -f "${1:?arms dir}"); OUT=$(readlink -f "${2:?outdir}"); mkdir -p "$OUT"
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
find "$SRC" -name '*.sv' | sort > "$OUT/LISTED"
LISTED=$(wc -l < "$OUT/LISTED"); PROCESSED=0; DIFFS=0
printf "%-34s %6s %6s %6s %6s %10s %10s %s\n" ARM pRC qRC pERC qERC PRIS_CMP PAT_CMP VERDICT
while read -r f <&3; do
  rel=${f#$SRC/}; key=$(echo "$rel" | tr '/' '_')
  W="$OUT/$key.d"; mkdir -p "$W"; cp "$f" "$W/"
  for h in "$(dirname "$f")"/*_inc*.svh; do [ -f "$h" ] && cp "$h" "$W/"; done
  b=$(basename "$f")
  ( cd "$W" && "$SL" -parse -nobuiltin -nocache -sv "$b" >sl.log 2>&1 </dev/null )
  for c in slpp_all slpp_unit; do [ -f "$W/$c/surelog.uhdm" ] && cp "$W/$c/surelog.uhdm" "$W/g.uhdm"; done
  ( cd "$W" && "$PRIS"    "$b"            -o o.uhdm  >o.log  2>&1 </dev/null ); prc=$?
  ( cd "$W" && "$PATCHED" "$b"            -o q.uhdm  >q.log  2>&1 </dev/null ); qrc=$?
  ( cd "$W" && "$PRIS"    "$b" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); perc=$?
  ( cd "$W" && "$PATCHED" "$b" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); qerc=$?
  pl=-; ql=-
  if [ -f "$W/g.uhdm" ] && [ -f "$W/o.uhdm" ]; then "$CMP" "$W/g.uhdm" "$W/o.uhdm" > "$W/o.cmp" 2>&1; pl=$(wc -l < "$W/o.cmp"); fi
  if [ -f "$W/g.uhdm" ] && [ -f "$W/q.uhdm" ]; then "$CMP" "$W/g.uhdm" "$W/q.uhdm" > "$W/q.cmp" 2>&1; ql=$(wc -l < "$W/q.cmp"); fi
  V=SAME
  [ "$prc" != "$qrc" ] && V=RC-DIFF
  [ "$perc" != "$qerc" ] && V=ERC-DIFF
  if [ "$pl" != "$ql" ]; then V=CMP-DIFF; fi
  # the ELAB view must move exactly as the DEF view does: byte-compare both
  if [ -f "$W/oe.uhdm" ] && [ -f "$W/qe.uhdm" ]; then
    if cmp -s "$W/oe.uhdm" "$W/qe.uhdm"; then eb=ELAB-SAME; else eb=ELAB-MOVED; fi
  else eb=ELAB-NOFILE; fi
  [ "$V" != SAME ] && DIFFS=$((DIFFS+1))
  printf "%-34s %6s %6s %6s %6s %10s %10s %s %s\n" "$rel" "$prc" "$qrc" "$perc" "$qerc" "$pl" "$ql" "$V" "$eb"
  PROCESSED=$((PROCESSED+1))
done 3< "$OUT/LISTED"
echo "LISTED=$LISTED PROCESSED=$PROCESSED CMP_OR_RC_DIFFS=$DIFFS"
[ "$LISTED" = "$PROCESSED" ] || { echo "FATAL: the gate did not reach every arm"; exit 3; }
