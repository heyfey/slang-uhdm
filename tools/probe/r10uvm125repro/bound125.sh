#!/usr/bin/env bash
# r10uvm125 — THE WIDE BOUNDARY GATE.  Every .sv/.v arm committed under
# tools/probe/ (SUBDIRECTORIES INCLUDED) is built with the PRISTINE and the
# PATCHED binary in BOTH views and the two databases are compared BYTE FOR BYTE.
# Only cells the law names may differ.
#
# GUARDS (each an ops trap this campaign has paid for):
#   * the file list is read on fd 3 and every child gets </dev/null, so no child
#     can swallow the list;
#   * PROCESSED is asserted against LISTED — a gate that reaches nothing must
#     never read as green;
#   * scratch is keyed on the RELATIVE path (three arms are named dut.sv);
#   * rc is recorded per cell (a segfault is not a pass);
#   * NO path filter: the list is taken whole.
# MEASUREMENT ONLY — the official uhdm-cmp is the judge.
#   usage: PRIS=.. PATCHED=.. bound125.sh <probe-root> <outdir>
set -u
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
ROOT=$(readlink -f "$1"); OUT=$(readlink -f "$2"); mkdir -p "$OUT"
LIST="$OUT/list.txt"
find "$ROOT" -type f \( -name '*.sv' -o -name '*.v' \) | sort > "$LIST"
LISTED=$(wc -l < "$LIST"); PROCESSED=0; DIFFER=0; RCBAD=0
: > "$OUT/cells.txt"
exec 3< "$LIST"
while IFS= read -r f <&3; do
  PROCESSED=$((PROCESSED+1))
  rel=${f#"$ROOT"/}; key=$(echo "$rel" | tr '/' '_')
  d="$OUT/w/$key"; mkdir -p "$d"; cp "$f" "$d/src${f##*.sv}" 2>/dev/null
  b=$(basename "$f"); cp "$f" "$d/$b"
  for v in "" "--elabuhdm"; do
    tag=def; [ -n "$v" ] && tag=elab
    ( cd "$d" && "$PRIS"    "$b" $v -o "p.$tag.uhdm" > "p.$tag.log" 2>&1 </dev/null ); rp=$?
    ( cd "$d" && "$PATCHED" "$b" $v -o "q.$tag.uhdm" > "q.$tag.log" 2>&1 </dev/null ); rq=$?
    st=SAME
    if [ "$rp" != "$rq" ]; then st=RC_DIFF; RCBAD=$((RCBAD+1));
    elif [ -f "$d/p.$tag.uhdm" ] && [ -f "$d/q.$tag.uhdm" ]; then
      cmp -s "$d/p.$tag.uhdm" "$d/q.$tag.uhdm" || { st=BYTES_DIFFER; DIFFER=$((DIFFER+1)); }
    elif [ -f "$d/p.$tag.uhdm" ] || [ -f "$d/q.$tag.uhdm" ]; then
      st=ONE_SIDE_ONLY; DIFFER=$((DIFFER+1))
    else st=NO_DB; fi
    echo -e "$st\t$rel\t$tag\trc=$rp/$rq" >> "$OUT/cells.txt"
  done
  rm -f "$d"/*.uhdm
done
exec 3<&-
echo "LISTED=$LISTED PROCESSED=$PROCESSED DIFFER=$DIFFER RC_DIFF=$RCBAD"
[ "$LISTED" = "$PROCESSED" ] || echo "ASSERT-FAIL: PROCESSED != LISTED"
grep -vE '^SAME' "$OUT/cells.txt" | sort | head -80
