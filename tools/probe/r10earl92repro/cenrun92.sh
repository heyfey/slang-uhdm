#!/usr/bin/env bash
# r10earl92 — THE CORPUS-WIDE CENSUS RUNNER.  MEASUREMENT ONLY.
#
# cen92.sh keeps every row file; on the surelog corpus that is gigabytes and
# the WSL VHDX has already been filled once by this campaign (RESUME §9).  This
# driver censuses ONE database at a time, scores it, records the per-database
# bucket counts AND every DIFFERING cell VERBATIM, then deletes the rows.
#
# It READS databases and DISPATCHES NOTHING — no test, fenced or otherwise, is
# ever run by this script.  The golden path comes from each test's OWN
# cmds.txt, so the census cannot silently read the wrong golden.
#
#   usage: cenrun92.sh <workdir> <outfile-prefix>
#   env:   CEN92 (path to ct92cen), SCORE92 (path to score92.py)
set -u
WD=${1:?workdir}; OUT=${2:?out prefix}
CEN=${CEN92:?set CEN92}; SC=${SCORE92:?set SCORE92}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
T=$(mktemp -d /tmp/r10earl92_cenrun.XXXXXX)
: > "$OUT.counts"; : > "$OUT.diffcells"
n=0; nog=0
for d in "$WD"/*/*/; do
  [ -f "$d/slang.uhdm" ] || continue
  [ -f "$d/cmds.txt" ]   || continue
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then nog=$((nog+1)); continue; fi
  rel=${d#"$WD"/}; rel=${rel%/}; tag=${rel//\//__}
  "$CEN" "$d/slang.uhdm" --inst 2>/dev/null > "$T/o"
  "$CEN" "$G"            --inst 2>/dev/null > "$T/g"
  if [ ! -s "$T/o" ] && [ ! -s "$T/g" ]; then continue; fi
  n=$((n+1))
  for fam in CA CO; do
    echo -n "$tag $fam "
    python3 "$SC" "$T/g" "$T/o" --fam $fam | head -1
  done >> "$OUT.counts"
  # every ELAB cell whose Rhs fingerprint differs, verbatim, both sides
  python3 "$SC" "$T/g" "$T/o" --fam CA --dump-diff 100000 \
    | sed -n '2,$p' | sed "s#^#$tag #" >> "$OUT.diffcells"
  python3 "$SC" "$T/g" "$T/o" --fam CO --dump-diff 100000 \
    | sed -n '2,$p' | sed "s#^#$tag #" >> "$OUT.diffcells"
done
rm -rf "$T"
echo "-- databases censused=$n  no-golden=$nog"
