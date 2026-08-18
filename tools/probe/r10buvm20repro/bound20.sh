#!/usr/bin/env bash
# r10buvm20repro/bound20.sh — THE BOUNDARY GATE (carried forward from r10buvm18repro/bound18.sh, unchanged apart from the default OUT path).
# Compiles EVERY .sv arm in EVERY tools/probe/*repro/ SUBDIRECTORY with both
# binaries and asserts the uhdm-dump TEXT is byte-identical, so that any
# bind-window law whose arm lives in the tree (buvm13/15, uvm88, uvm90, sd*,
# classArgBind12, 28/57/64 ...) is proved untouched.
#
# GUARDS: the arm list is carried on fd 3 (a child that reads stdin cannot eat
# it), every child gets </dev/null, PROCESSED is asserted against the list
# length, and all scratch is keyed on the arm's RELATIVE path so two arms with
# the same basename in different dirs cannot collide.
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"; : "${ROOT:?probe root}"
OUT=${OUT:-/tmp/r10buvm20_bound}
rm -rf "$OUT"; mkdir -p "$OUT"
LIST=$OUT/arms.txt
( cd "$ROOT" && find . -name '*.sv' -type f | LC_ALL=C sort ) > "$LIST"
N=$(wc -l < "$LIST")
echo "== boundary gate: $N arms under $ROOT"
proc=0; diffn=0; rejp=0; rejq=0
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  proc=$((proc+1))
  key=$(printf '%s' "$rel" | sed 's#^\./##; s#/#__#g; s#\.sv$##')
  d="$OUT/$key"; mkdir -p "$d"
  cp "$ROOT/$rel" "$d/a.sv"
  ( cd "$d" && "$PRISTINE" a.sv -o p.uhdm >p.log 2>&1 ) </dev/null
  ( cd "$d" && "$PATCHED"  a.sv -o q.uhdm >q.log 2>&1 ) </dev/null
  if [ ! -s "$d/p.uhdm" ] && [ ! -s "$d/q.uhdm" ]; then
     rejp=$((rejp+1)); rejq=$((rejq+1)); echo "BOTH-REJECT $rel" >> "$OUT/reject.txt"; rm -rf "$d"; continue
  fi
  if [ ! -s "$d/p.uhdm" ]; then rejp=$((rejp+1)); echo "PRIS-ONLY-REJECT $rel" >> "$OUT/asym.txt"; fi
  if [ ! -s "$d/q.uhdm" ]; then rejq=$((rejq+1)); echo "PATCHED-ONLY-REJECT $rel" >> "$OUT/asym.txt"; fi
  if [ -s "$d/p.uhdm" ] && [ -s "$d/q.uhdm" ]; then
    # THE BANNER TRAP, paid for on the first run of this gate: uhdm-dump's FIRST
    # line is `<file>: Restored design Pre-Elab:`, so comparing p.uhdm's dump to
    # q.uhdm's dump makes EVERY arm differ by that one line and the gate reported
    # 2588 / 2712 "differing" arms.  The banner is normalised away here; the real
    # answer on this tree is FOUR.
    ( cd "$d" && uhdm-dump p.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > p.txt
                 uhdm-dump q.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > q.txt ) </dev/null
    if ! cmp -s "$d/p.txt" "$d/q.txt"; then
      diffn=$((diffn+1)); echo "$rel" >> "$OUT/differ.txt"
      diff "$d/p.txt" "$d/q.txt" > "$d/diff.txt" 2>&1
    else
      rm -rf "$d"
    fi
  fi
done
exec 3<&-
echo "PROCESSED=$proc LISTED=$N DIFFER=$diffn PRIS_REJECT=$rejp PATCHED_REJECT=$rejq"
[ "$proc" = "$N" ] || { echo "FATAL: PROCESSED != LISTED"; exit 9; }
[ -s "$OUT/asym.txt" ] && { echo "FATAL: ASYMMETRIC REJECT"; cat "$OUT/asym.txt"; }
if [ "$diffn" -gt 0 ]; then echo "-- differing arms:"; cat "$OUT/differ.txt"; fi
