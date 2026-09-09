#!/bin/bash
# r10uvm227 — run the CELL CENSUS (ct227cen + cen227.py) over a named set of
# row-modes, golden vs PRISTINE vs PATCHED.  MEASUREMENT ONLY; `uhdm-cmp` is
# the sole acceptance judge.
#
#   usage: bash cenrun227.sh <pristine-workdir> <patched-workdir> <out.txt> [rowlist]
#
# `rowlist` is a file of `<mode>/<dir>` tags (the same tags predict227.sh
# prints); with no list, EVERY row-mode of the workdir is censused.
# The golden path is read out of each row's OWN cmds.txt, so this cannot
# silently compare against the wrong golden, and the cache DIRECTORY is turned
# into `.../golden.uhdm` (handing a directory to the probe censuses nothing).
# A row whose golden or database is missing prints SKIP-NOFILE and is COUNTED.
set -u
P=${1:?pristine workdir}
Q=${2:?patched workdir}
OUT=${3:?out}
LIST=${4:-}
CEN=${CEN:-/tmp/r10uvm227_ct227cen}
JOIN=${JOIN:-$(cd "$(dirname "$0")" && pwd)/cen227.py}
[ -x "$CEN" ] || { echo "FATAL: no ct227cen at $CEN"; exit 3; }
: > "$OUT"
tmp=$(mktemp /tmp/r10uvm227_cenlist.XXXXXX)
if [ -n "$LIST" ]; then
    cp "$LIST" "$tmp"
else
    (cd "$P" && find . -name slang.uhdm | sed 's#^\./##; s#/slang.uhdm$##') > "$tmp"
fi
listed=$(grep -c . "$tmp"; true)
proc=0; skip=0
while read -r tag <&3; do
    proc=$((proc+1))
    pd="$P/$tag"; qd="$Q/$tag"
    G=""
    [ -f "$pd/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$pd/cmds.txt" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$pd/slang.uhdm" ] || [ ! -f "$qd/slang.uhdm" ]; then
        echo "SKIP-NOFILE $tag (g=${G:-none})" >> "$OUT"
        skip=$((skip+1)); continue
    fi
    k=$(echo "$tag" | sed 's#/#__#g')
    "$CEN" "$G"              > "/tmp/r10uvm227_cen.$k.g"   2>&1
    "$CEN" "$pd/slang.uhdm"  > "/tmp/r10uvm227_cen.$k.p"   2>&1
    "$CEN" "$qd/slang.uhdm"  > "/tmp/r10uvm227_cen.$k.q"   2>&1
    # CALIBRATE golden against ITSELF first: anything but all-AGREE means the
    # key is wrong and every verdict below it would be noise.
    python3 "$JOIN" "/tmp/r10uvm227_cen.$k.g" "/tmp/r10uvm227_cen.$k.g" \
        "/tmp/r10uvm227_cen.$k.g" "CALIB $tag" | tail -1 >> "$OUT"
    python3 "$JOIN" "/tmp/r10uvm227_cen.$k.g" "/tmp/r10uvm227_cen.$k.p" \
        "/tmp/r10uvm227_cen.$k.q" "$tag" >> "$OUT"
done 3< "$tmp"
rm -f "$tmp"
echo "cenrun227: LISTED $listed PROCESSED $proc SKIP-NOFILE $skip" >> "$OUT"
tail -1 "$OUT"
[ "$listed" = "$proc" ] || { echo "  !! LISTED != PROCESSED"; exit 4; }
echo "--- totals"
grep -h '^-- ' "$OUT" | grep -v '^-- CALIB' | awk '{for(i=1;i<=NF;i++){if($i=="AGREE")a+=$(i+1); if($i=="TO-GOLDEN")t+=$(i+1); if($i=="AWAY-GOLDEN")w+=$(i+1); if($i=="MOVED-WRONG")m+=$(i+1); if($i=="STILL-WRONG")s+=$(i+1)}} END{printf "AGREE %d  TO-GOLDEN %d  AWAY-GOLDEN %d  MOVED-WRONG %d  STILL-WRONG %d\n",a,t,w,m,s}'
echo "--- calibration rows that are NOT all-AGREE (must be none)"
grep -h '^-- CALIB' "$OUT" | grep -vE 'TO-GOLDEN 0  AWAY-GOLDEN 0  MOVED-WRONG 0  STILL-WRONG 0' || echo "(none)"
