#!/usr/bin/env bash
# r10vbuvm34repro/vbound34.sh — THE VERIFIER'S BOUNDARY GATE.  bound34.sh's
# shape (fd-3 arm list, children </dev/null, PROCESSED asserted, scratch keyed
# on the RELATIVE path, the `Restored design` banner normalised) plus an RC
# LEDGER: every cell's two rcs are recorded even when the cell agrees, so
# "0 differing" can never be a silent both-reject.
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"; : "${ROOT:?probe root (a COPY)}"
OUT=${OUT:-/tmp/vbuvm34_bound}
MODE=${MODE:-file}
VIEW=${VIEW:-def}
EF=""; [ "$VIEW" = elab ] && EF="--elabuhdm"
rm -rf "$OUT"; mkdir -p "$OUT"
LIST=$OUT/arms.txt; LEDGER=$OUT/rc.tsv; : > "$LEDGER"
if [ "$MODE" = dir ]; then
  ( cd "$ROOT" && find . \( -name '*.sv' -o -name '*.v' \) -type f -printf '%h\n' | LC_ALL=C sort -u ) > "$LIST"
else
  ( cd "$ROOT" && find . \( -name '*.sv' -o -name '*.v' \) -type f | LC_ALL=C sort ) > "$LIST"
fi
N=$(wc -l < "$LIST")
echo "== vbound: MODE=$MODE VIEW=$VIEW  $N arms under $ROOT"
proc=0; diffn=0; rejp=0; rejq=0
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  proc=$((proc+1))
  key=$(printf '%s' "$rel" | sed 's#^\./##; s#/#__#g; s#\.\(sv\|v\)$##')
  [ -n "$key" ] && [ "$key" != "." ] || key=ROOT
  d="$OUT/$key"; mkdir -p "$d"
  if [ "$MODE" = dir ]; then
    srcs=(); while IFS= read -r f; do srcs+=("$ROOT/$rel/$f"); done < <(cd "$ROOT/$rel" && ls *.sv *.v 2>/dev/null | LC_ALL=C sort)
  else
    cp "$ROOT/$rel" "$d/a.${rel##*.}"; srcs=("$d/a.${rel##*.}")
  fi
  ( cd "$d" && "$PRISTINE" "${srcs[@]}" $EF -o p.uhdm >p.log 2>&1; echo "rc=$?" >> p.log ) </dev/null
  ( cd "$d" && "$PATCHED"  "${srcs[@]}" $EF -o q.uhdm >q.log 2>&1; echo "rc=$?" >> q.log ) </dev/null
  rp=$(sed -n 's/^rc=//p' "$d/p.log" | tail -1); rq=$(sed -n 's/^rc=//p' "$d/q.log" | tail -1)
  vd=UNSET
  if [ ! -s "$d/p.uhdm" ] && [ ! -s "$d/q.uhdm" ]; then
     rejp=$((rejp+1)); rejq=$((rejq+1)); vd=BOTH-REJECT
     echo "BOTH-REJECT $rel" >> "$OUT/reject.txt"
     printf '%s\t%s\t%s\t%s\n' "$rel" "$rp" "$rq" "$vd" >> "$LEDGER"; rm -rf "$d"; continue
  fi
  [ -s "$d/p.uhdm" ] || { rejp=$((rejp+1)); echo "PRIS-ONLY-REJECT $rel" >> "$OUT/asym.txt"; }
  [ -s "$d/q.uhdm" ] || { rejq=$((rejq+1)); echo "PATCHED-ONLY-REJECT $rel" >> "$OUT/asym.txt"; }
  if [ -s "$d/p.uhdm" ] && [ -s "$d/q.uhdm" ]; then
    ( cd "$d" && uhdm-dump p.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > p.txt
                 uhdm-dump q.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > q.txt ) </dev/null
    if ! cmp -s "$d/p.txt" "$d/q.txt"; then
      diffn=$((diffn+1)); vd=DIFFER; echo "$rel" >> "$OUT/differ.txt"
      diff "$d/p.txt" "$d/q.txt" > "$d/diff.txt" 2>&1
    else
      vd=SAME; rm -rf "$d"
    fi
  else
    vd=ASYM
  fi
  printf '%s\t%s\t%s\t%s\n' "$rel" "$rp" "$rq" "$vd" >> "$LEDGER"
done
exec 3<&-
echo "PROCESSED=$proc LISTED=$N DIFFER=$diffn PRIS_REJECT=$rejp PATCHED_REJECT=$rejq LEDGER=$(wc -l < "$LEDGER")"
[ "$proc" = "$N" ] || { echo "FATAL: PROCESSED != LISTED"; exit 9; }
[ -f "$OUT/asym.txt" ] && { echo "FATAL: ASYMMETRIC REJECT"; cat "$OUT/asym.txt"; }
if [ "$diffn" -gt 0 ]; then echo "-- differing arms:"; cat "$OUT/differ.txt"; fi
exit 0
