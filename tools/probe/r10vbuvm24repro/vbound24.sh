#!/usr/bin/env bash
# r10vbuvm24repro/vbound24.sh — THE VERIFIER'S BOUNDARY GATE.
#
# Compiles EVERY .sv AND .v arm under a COPY of the WHOLE probe tree (no path
# filter) with both binaries, in one view, and asserts the databases are
# byte-identical (falling back to the uhdm-dump TEXT so a pure id/address shift
# is still reported rather than hidden).  MODE=file compiles each arm alone;
# MODE=dir compiles every arm of a directory TOGETHER (the sd8-12 arms live in
# SUBDIRECTORIES; a top-level glob runs nothing and prints green).
#
# GUARDS: the arm list rides fd 3 (a child that reads stdin cannot eat it),
# every child gets </dev/null, PROCESSED is asserted against LISTED, scratch is
# keyed on the RELATIVE path (three different `dut.sv` exist), the rc of BOTH
# binaries is recorded per cell, and an ASYMMETRIC reject is fatal.
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"; : "${ROOT:?probe root (a COPY)}"
OUT=${OUT:-/tmp/vbuvm24_bound}
MODE=${MODE:-file}
VIEW=${VIEW:-def}
EF=""; [ "$VIEW" = elab ] && EF="--elabuhdm"
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
rm -rf "$OUT"; mkdir -p "$OUT"
LIST=$OUT/arms.txt
if [ "$MODE" = dir ]; then
  ( cd "$ROOT" && find . \( -name '*.sv' -o -name '*.v' \) -type f -printf '%h\n' | LC_ALL=C sort -u ) > "$LIST"
else
  ( cd "$ROOT" && find . \( -name '*.sv' -o -name '*.v' \) -type f | LC_ALL=C sort ) > "$LIST"
fi
N=$(wc -l < "$LIST")
echo "== VBOUNDARY MODE=$MODE VIEW=$VIEW  $N arms under $ROOT"
proc=0; diffn=0; rejp=0; rejq=0
: > "$OUT/rc.txt"
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  proc=$((proc+1))
  key=$(printf '%s' "$rel" | sed 's#^\./##; s#/#__#g; s#\.\(sv\|v\)$##')
  d="$OUT/$key"; mkdir -p "$d"
  if [ "$MODE" = dir ]; then
    srcs=(); while IFS= read -r f; do srcs+=("$ROOT/$rel/$f"); done < <(cd "$ROOT/$rel" && ls *.sv *.v 2>/dev/null | LC_ALL=C sort)
  else
    cp "$ROOT/$rel" "$d/a.${rel##*.}"; srcs=("$d/a.${rel##*.}")
  fi
  ( cd "$d" && "$PRISTINE" "${srcs[@]}" $EF -o p.uhdm >p.log 2>&1; echo "rc=$?" >> p.log ) </dev/null
  ( cd "$d" && "$PATCHED"  "${srcs[@]}" $EF -o q.uhdm >q.log 2>&1; echo "rc=$?" >> q.log ) </dev/null
  prc=$(tail -1 "$d/p.log"); qrc=$(tail -1 "$d/q.log")
  echo "$rel p:$prc q:$qrc" >> "$OUT/rc.txt"
  if [ ! -s "$d/p.uhdm" ] && [ ! -s "$d/q.uhdm" ]; then
     rejp=$((rejp+1)); rejq=$((rejq+1)); echo "BOTH-REJECT $rel $prc $qrc" >> "$OUT/reject.txt"; rm -rf "$d"; continue
  fi
  [ -s "$d/p.uhdm" ] || { rejp=$((rejp+1)); echo "PRIS-ONLY-REJECT $rel" >> "$OUT/asym.txt"; }
  [ -s "$d/q.uhdm" ] || { rejq=$((rejq+1)); echo "PATCHED-ONLY-REJECT $rel" >> "$OUT/asym.txt"; }
  if [ -s "$d/p.uhdm" ] && [ -s "$d/q.uhdm" ]; then
    if cmp -s "$d/p.uhdm" "$d/q.uhdm"; then rm -rf "$d"; continue; fi
    ( cd "$d" && "$DUMP" p.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > p.txt
                 "$DUMP" q.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > q.txt ) </dev/null
    if ! cmp -s "$d/p.txt" "$d/q.txt"; then
      diffn=$((diffn+1)); echo "$rel" >> "$OUT/differ.txt"
      diff "$d/p.txt" "$d/q.txt" > "$d/diff.txt" 2>&1
      # ORDER-BLIND companion: a parallel-parse COIN sorts to zero lines.
      sort "$d/p.txt" > "$d/p.s"; sort "$d/q.txt" > "$d/q.s"
      echo "$rel orderblind=$(diff "$d/p.s" "$d/q.s" | grep -cE '^[<>]' || true)" >> "$OUT/orderblind.txt"
    else
      diffn=$((diffn+1)); echo "$rel (BYTES ONLY)" >> "$OUT/differ.txt"
    fi
  fi
done
exec 3<&-
echo "PROCESSED=$proc LISTED=$N DIFFER=$diffn PRIS_REJECT=$rejp PATCHED_REJECT=$rejq"
[ "$proc" = "$N" ] || { echo "FATAL: PROCESSED != LISTED"; exit 9; }
[ -s "$OUT/asym.txt" ] && { echo "FATAL: ASYMMETRIC REJECT"; cat "$OUT/asym.txt"; }
if [ "$diffn" -gt 0 ]; then echo "-- differing arms:"; cat "$OUT/differ.txt"; fi
[ -f "$OUT/orderblind.txt" ] && { echo "-- order-blind:"; cat "$OUT/orderblind.txt"; }
exit 0
