#!/usr/bin/env bash
# r10uvm188 -- THE BOUNDARY GATE (descended verbatim from r10uvm170repro/bound170.sh,
# itself from r10uvm157repro/bound157.sh), run from a COPY of the probe tree so no path
# filter can hide an arm.  It compiles EVERY .sv/.v in the copy (top level AND
# SUBDIRECTORIES), in BOTH views, with the pristine and the patched binary, and
# reports every arm whose rc or whose DATABASE BYTES moved.  Byte-identity is a
# STRICTLY STRONGER test than a cmp-line count (it sees a change golden also
# has), which is why the golden side is only built for the arms that MOVED —
# there the law must name the cells, and uhdm-cmp is the judge of them.
#
# Every child gets </dev/null; the file list is read on fd 3; PROCESSED is
# asserted against LISTED; scratch is keyed on the RELATIVE path (three arms in
# this tree are all named dut.sv).  This pass's own probe0.sv + grid188/g188_*.sv are the POSITIVE
# CONTROL: a gate that reports zero movers over them cannot see.
#   usage: PRIS=.. PATCHED=.. bound188.sh <dir-of-arms> <outdir>
set -u
SRC=$(readlink -f "${1:?arms dir}"); OUT=$(readlink -f "${2:?outdir}"); mkdir -p "$OUT"
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
find "$SRC" \( -name '*.sv' -o -name '*.v' \) | sort > "$OUT/LISTED"
LISTED=$(wc -l < "$OUT/LISTED"); PROCESSED=0; MOVED=0; RCD=0; PRODUCED=0
: > "$OUT/MOVERS"
while read -r f <&3; do
  rel=${f#$SRC/}; key=$(echo "$rel" | tr '/' '_')
  W="$OUT/$key.d"; mkdir -p "$W"; cp "$f" "$W/" 2>/dev/null
  for h in "$(dirname "$f")"/*.svh "$(dirname "$f")"/*.vh; do [ -f "$h" ] && cp "$h" "$W/"; done
  b=$(basename "$f")
  # NO language flag: our binary has no `-sv` and rejects it -- a first cut of
  # this gate passed one and ran NOTHING while printing MOVED_ARMS=0.  The
  # PRODUCED counter below is what convicts that class of green-on-nothing.
  ( cd "$W" && "$PRIS"    "$b"            -o o.uhdm  >o.log  2>&1 </dev/null ); prc=$?
  ( cd "$W" && "$PATCHED" "$b"            -o q.uhdm  >q.log  2>&1 </dev/null ); qrc=$?
  ( cd "$W" && "$PRIS"    "$b" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); perc=$?
  ( cd "$W" && "$PATCHED" "$b" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); qerc=$?
  [ -f "$W/o.uhdm" ] && PRODUCED=$((PRODUCED+1))
  V=SAME
  [ "$prc" != "$qrc" ] && { V=RC-DIFF; RCD=$((RCD+1)); }
  [ "$perc" != "$qerc" ] && { V=ERC-DIFF; RCD=$((RCD+1)); }
  db=SAME; eb=SAME
  if [ -f "$W/o.uhdm" ] || [ -f "$W/q.uhdm" ]; then cmp -s "$W/o.uhdm" "$W/q.uhdm" 2>/dev/null || db=MOVED; fi
  if [ -f "$W/oe.uhdm" ] || [ -f "$W/qe.uhdm" ]; then cmp -s "$W/oe.uhdm" "$W/qe.uhdm" 2>/dev/null || eb=MOVED; fi
  if [ "$db" = MOVED ] || [ "$eb" = MOVED ]; then
    MOVED=$((MOVED+1)); printf "%s\tdef=%s\telab=%s\trc=%s/%s,%s/%s\n" "$rel" "$db" "$eb" "$prc" "$qrc" "$perc" "$qerc" >> "$OUT/MOVERS"
  fi
  [ "$V" != SAME ] && printf "RCDIFF\t%s\t%s/%s\t%s/%s\n" "$rel" "$prc" "$qrc" "$perc" "$qerc" >> "$OUT/MOVERS"
  PROCESSED=$((PROCESSED+1))
  rm -f "$W"/*.uhdm
done 3< "$OUT/LISTED"
echo "LISTED=$LISTED PROCESSED=$PROCESSED PRODUCED_DBS=$PRODUCED MOVED_ARMS=$MOVED RC_DIFFS=$RCD"
[ "$LISTED" = "$PROCESSED" ] || { echo "FATAL: the gate did not reach every arm"; exit 3; }
