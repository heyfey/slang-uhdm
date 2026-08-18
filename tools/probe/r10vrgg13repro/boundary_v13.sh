#!/usr/bin/env bash
# vrgg13 WIDE boundary — every .sv/.v arm under a COPY of tools/probe, compiled
# with BOTH frozen binaries and compared byte-wise.
#   * file list on FD 3 (never stdin), children </dev/null  (RESUME §9)
#   * PROCESSED asserted == LISTED
#   * uncompilable / asymmetry counted, never skipped
#   * FENCED tests are never named or dispatched (none live under tools/probe)
set -u
A=/tmp/vrgg13_bin/slang-uhdm-base
B=/tmp/vrgg13_bin/slang-uhdm-pat
ROOT=${1:?root}
OUT=${2:?out}
LIST=/tmp/vrgg13_bnd_list.txt
find "$ROOT" -type f \( -name '*.sv' -o -name '*.v' \) -not -path '*/slpp_all/*' | LC_ALL=C sort > "$LIST"
LISTED=$(wc -l < "$LIST")
same=0; mov=0; nocomp=0; asym=0; n=0
{
echo "LISTED=$LISTED"
while IFS= read -r f <&3; do
  n=$((n+1))
  wa=/tmp/vrgg13_bnd_a.uhdm; wb=/tmp/vrgg13_bnd_b.uhdm
  rm -f "$wa" "$wb"
  ( cd "$(dirname "$f")" && "$A" "$(basename "$f")" --single-unit -o "$wa" >/dev/null 2>&1 </dev/null )
  ra=$?
  ( cd "$(dirname "$f")" && "$B" "$(basename "$f")" --single-unit -o "$wb" >/dev/null 2>&1 </dev/null )
  rb=$?
  rel=${f#$ROOT/}
  if [ ! -f "$wa" ] && [ ! -f "$wb" ]; then
    echo "UNCOMPILABLE $rel (rc $ra/$rb)"; nocomp=$((nocomp+1))
  elif [ ! -f "$wa" ] || [ ! -f "$wb" ]; then
    echo "ASYMMETRY $rel (base rc=$ra pat rc=$rb)"; asym=$((asym+1))
  elif cmp -s "$wa" "$wb"; then
    same=$((same+1))
  else
    echo "MOVER $rel (base rc=$ra pat rc=$rb sizes $(stat -c%s $wa)/$(stat -c%s $wb))"; mov=$((mov+1))
  fi
  rm -f "$wa" "$wb"
done 3< "$LIST"
echo "-- PROCESSED=$n LISTED=$LISTED identical=$same MOVERS=$mov uncompilable=$nocomp asymmetries=$asym"
[ "$n" = "$LISTED" ] && echo "PROCESSED-ASSERT OK" || echo "PROCESSED-ASSERT FAIL"
} > "$OUT" 2>&1
tail -3 "$OUT"
