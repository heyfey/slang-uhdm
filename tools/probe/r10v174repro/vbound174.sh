#!/usr/bin/env bash
# r10v174repro/vbound174.sh — the VERIFIER's WIDE BOUNDARY GATE.
# MEASUREMENT ONLY.
#
# Compiles EVERY .sv/.v in the committed probe tree — top level AND
# subdirectories — with both frozen binaries in BOTH views and byte-compares
# the databases.  The wide boundary is the only instrument that convicts a
# corpus-invisible regression in another pass's arms.
#
# TRAPS THIS GATE IS BUILT AGAINST (RESUME.md §9):
#   * subdirectory arms — a top-level glob runs nothing and prints green;
#   * the file list is read on fd 3 and every child gets </dev/null, so no
#     child can swallow the list;
#   * PROCESSED is asserted equal to LISTED;
#   * scratch is keyed on the RELATIVE path (r10uvm33repro has three dut.sv);
#   * every rc is recorded and rc DIFFERENCES between the binaries are counted
#     (an rc=139 segfault must never read as a result).
#
#   vbound174.sh <probe-tree-root> <out-dir> <binA:pristine> <binB:patched> [jobs]
set -u
ROOT=$(readlink -f "$1"); OUT=$2; A=$3; B=$4; J=${5:-4}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$OUT"
LIST="$OUT/LIST.txt"
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f | sort > "$LIST"
LISTED=$(wc -l < "$LIST")
echo "LISTED=$LISTED"

one() {
  f=$1
  rel=${f#"$ROOT"/}
  key=$(printf '%s' "$rel" | tr '/' '_')
  d="$OUT/w/$key"
  mkdir -p "$d"
  st=""
  for v in def elab; do
    EF=""; [ "$v" = elab ] && EF="--elabuhdm"
    "$A" "$f" $EF -o "$d/a_$v.uhdm" > /dev/null 2>&1 </dev/null; ra=$?
    "$B" "$f" $EF -o "$d/b_$v.uhdm" > /dev/null 2>&1 </dev/null; rb=$?
    same=NA
    if [ -f "$d/a_$v.uhdm" ] && [ -f "$d/b_$v.uhdm" ]; then
      if cmp -s "$d/a_$v.uhdm" "$d/b_$v.uhdm"; then same=SAME; else same=MOVED; fi
    fi
    rcd=RCSAME; [ "$ra" != "$rb" ] && rcd=RCDIFF
    st="$st $v:$same:$rcd:ra=$ra:rb=$rb"
  done
  printf 'PROCESSED\t%s\t%s\n' "$rel" "$st"
  rm -f "$d"/*.uhdm
}
export -f one
export ROOT OUT A B

xargs -a "$LIST" -P "$J" -I{} bash -c 'one "$@"' _ {} > "$OUT/ROWS.txt" 2>"$OUT/ERR.txt"

PROCESSED=$(grep -c '^PROCESSED' "$OUT/ROWS.txt" ; true)
MOVED=$(grep -c 'MOVED' "$OUT/ROWS.txt" ; true)
RCDIFF=$(grep -c 'RCDIFF' "$OUT/ROWS.txt" ; true)
echo "PROCESSED=$PROCESSED MOVED_ARMS=$MOVED RC_DIFFS=$RCDIFF"
[ "$PROCESSED" = "$LISTED" ] && echo "ASSERT PROCESSED==LISTED OK" || echo "ASSERT FAILED: PROCESSED($PROCESSED) != LISTED($LISTED)"
echo "-- moved arms:"
grep 'MOVED' "$OUT/ROWS.txt" | sort
echo "-- rc-differing arms:"
grep 'RCDIFF' "$OUT/ROWS.txt" | sort
