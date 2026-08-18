#!/usr/bin/env bash
# vbuvm19 verifier — PER-DIRECTORY boundary gate: every probe directory
# compiled as ONE unit (arms that only make sense together, e.g. a pkg + its
# users split across files, are invisible to a per-FILE gate).
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"; : "${ROOT:?}"
OUT=${OUT:-/tmp/vbuvm19_bounddir}
rm -rf "$OUT"; mkdir -p "$OUT"
LIST=$OUT/dirs.txt
( cd "$ROOT" && find . -name '*.sv' | sed 's|/[^/]*$||' | LC_ALL=C sort -u ) > "$LIST"
N=$(wc -l < "$LIST"); echo "== per-directory boundary: $N dirs under $ROOT"
proc=0; diffn=0; rejp=0; rejq=0; both=0
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  proc=$((proc+1))
  key=$(printf '%s' "$rel" | sed 's#^\./##; s#/#__#g')
  d="$OUT/$key"; mkdir -p "$d"
  ( cd "$ROOT/$rel" && "$PRISTINE" *.sv -o "$d/p.uhdm" >"$d/p.log" 2>&1 ) </dev/null
  ( cd "$ROOT/$rel" && "$PATCHED"  *.sv -o "$d/q.uhdm" >"$d/q.log" 2>&1 ) </dev/null
  if [ ! -s "$d/p.uhdm" ] && [ ! -s "$d/q.uhdm" ]; then both=$((both+1)); rm -rf "$d"; continue; fi
  [ -s "$d/p.uhdm" ] || { rejp=$((rejp+1)); echo "PRIS-ONLY-REJECT $rel" >> "$OUT/asym.txt"; }
  [ -s "$d/q.uhdm" ] || { rejq=$((rejq+1)); echo "PATCHED-ONLY-REJECT $rel" >> "$OUT/asym.txt"; }
  if [ -s "$d/p.uhdm" ] && [ -s "$d/q.uhdm" ]; then
    uhdm-dump "$d/p.uhdm" 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > "$d/p.txt"
    uhdm-dump "$d/q.uhdm" 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > "$d/q.txt"
    if ! cmp -s "$d/p.txt" "$d/q.txt"; then
      diffn=$((diffn+1)); echo "$rel" >> "$OUT/differ.txt"
      diff "$d/p.txt" "$d/q.txt" > "$d/diff.txt" 2>&1
    else rm -rf "$d"; fi
  fi
done
exec 3<&-
echo "PROCESSED=$proc LISTED=$N DIFFER=$diffn BOTH_REJECT=$both PRIS_REJECT=$rejp PATCHED_REJECT=$rejq"
[ "$proc" = "$N" ] || { echo "FATAL: PROCESSED != LISTED"; exit 9; }
[ -s "$OUT/asym.txt" ] && { echo "FATAL: ASYMMETRIC REJECT"; cat "$OUT/asym.txt"; }
[ -f "$OUT/differ.txt" ] && { echo "-- differing dirs:"; cat "$OUT/differ.txt"; }
true
