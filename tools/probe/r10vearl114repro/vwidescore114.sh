#!/usr/bin/env bash
# r10vearl114 WIDE-BOUNDARY RESCORER -- MEASUREMENT ONLY.
# Recomputes the identical/DIFFERING verdict from the RETAINED per-cell dumps
# with the side letter normalised out (the dump's first line names the file it
# restored).  Independent of the run, so a normalisation bug can be corrected
# without re-running 20 000 invocations.
#   bash vwidescore114.sh <outdir-prefix>
set -u
OUT=${1:?outdir}
# The fence list is READ OUT of canaudit.sh's own `FENCED=` line and never
# spelled here (spelling the four slang-fenced test names in a probe artifact
# is itself a FENCE-BREACH).
FENCED=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' "$(cd "$(dirname "$0")" && pwd)/canaudit.sh" | tr ' ' '|')
[ -n "$FENCED" ] || { echo "FATAL: no fence list in canaudit.sh"; exit 3; }
: > "$OUT.diff2"
while read -r rel; do
  key=$(echo "$rel" | sed 's#^\./##; s#/#__#g'); d="$OUT/run/$key"
  for view in plain elab; do
    if [ -f "$d/A.$view.txt" ] && [ -f "$d/B.$view.txt" ]; then
      if cmp -s <(sed 's#/K/A\.#/K/X.#g' "$d/A.$view.txt") \
                <(sed 's#/K/B\.#/K/X.#g' "$d/B.$view.txt"); then
        echo "identical $rel $view" >> "$OUT.diff2"
      else echo "DIFFERING $rel $view" >> "$OUT.diff2"; fi
    else echo "no_output $rel $view" >> "$OUT.diff2"; fi
  done
done < "$OUT.list"
{
echo "LISTED                        : $(wc -l < "$OUT.list")"
echo "FENCED-NAME HITS IN THE LIST  : $(grep -Ec "$FENCED" "$OUT.list"; true)"
echo "DISTINCT FILES IN THE rc LOG  : $(awk '{print $1}' "$OUT.rc" | sort -u | wc -l)"
echo "FILES WITH != 4 rc LINES      : $(awk '{c[$1]++} END{n=0; for(k in c) if(c[k]!=4) n++; print n+0}' "$OUT.rc")"
echo "FILES LISTED BUT NEVER RUN    : $(comm -23 <(sort -u "$OUT.list") <(awk '{print $1}' "$OUT.rc" | sort -u) | wc -l)"
echo "PROCESSED                     : $(awk '{print $2}' "$OUT.diff2" | sort -u | wc -l)"
echo "identical=$(grep -c '^identical' "$OUT.diff2"; true)  DIFFERING=$(grep -c '^DIFFERING' "$OUT.diff2"; true)  no_output=$(grep -c '^no_output' "$OUT.diff2"; true)"
echo "rc by side:"; awk '{print "  "$3"/"$4}' "$OUT.rc" | sort | uniq -c
echo "DIFFERING cells:"; grep '^DIFFERING' "$OUT.diff2" | sed 's/^DIFFERING //'
} > "$OUT.tally2"
cat "$OUT.tally2"
