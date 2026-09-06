#!/usr/bin/env bash
# r10uvm168repro/floor168.sh — score THIS pass's grid arms AND the committed
# arms of the two passes whose populations sit on the same objects (r10uvm159's
# folded-constant TYPESPEC law and r10earl104's minted int_typespec family):
# they are the MUST-STAY FLOOR, and both columns are scored explicitly.
# MEASUREMENT ONLY.
#   floor168.sh <binA:pristine> <binB:patched> <workroot>
# Every arm gets its OWN Surelog golden and its own workdir keyed on the
# RELATIVE path (RESUME §9: several passes name their arms the same thing), and
# the per-arm tally lines are echoed so an arm that scored NOTHING is visible.
set -u
A=${1:?pristine}; B=${2:?patched}; W=${3:?workroot}
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../../.." && pwd)
mkdir -p "$W"
ARMS=""
for f in "$HERE"/g168_*.sv; do ARMS="$ARMS $f"; done
for f in "$REPO"/tools/probe/r10uvm159repro/g159_*.sv; do [ -f "$f" ] && ARMS="$ARMS $f"; done
for f in "$REPO"/tools/probe/r10earl104repro/g[0-9]_*.sv; do [ -f "$f" ] && ARMS="$ARMS $f"; done
for f in "$REPO"/tools/probe/r10earl104repro/va[0-9]_*.sv "$REPO"/tools/probe/r10earl104repro/vb[0-9]_*.sv; do
  [ -f "$f" ] && ARMS="$ARMS $f"
done
n=0
for f in $ARMS; do
  rel=${f#$REPO/}
  key=$(echo "$rel" | tr '/.' '__')
  d="$W/$key"; mkdir -p "$d"
  bash "$HERE/grid168.sh" "$f" "$A" "$B" "$d" > "$d.grid.log" 2>&1 || true
  echo "=== ARM $rel"
  bash "$HERE/score168.sh" "$d" pa
  n=$((n+1))
done
echo "FLOOR arms=$n"
