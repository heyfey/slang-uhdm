#!/bin/bash
# r10earl111 -- run cen111 over EVERY database in a verify_golden workdir and
# score the TYPESPEC EDGE of every select-bound constant, golden vs ours.
#
# MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
# LHS is ALWAYS golden; RHS is ALWAYS ours.
#
#   usage: censweep111.sh <workdir> <outdir> [<workdir2> ...]
#
# GUARDS (each an ops trap this campaign has paid for):
#   * the golden path is read from the row's OWN cmds.txt (never guessed), and
#     the cache DIRECTORY is turned into .../golden.uhdm -- handing a tool a
#     directory measures nothing;
#   * BOTH sides are existence-checked and a missing side is COUNTED as SKIP,
#     so a driver that reaches nothing can never read as perfection;
#   * cen111 prints a terminating `CENRC 0`; a census whose output does not end
#     that way is a FAILED row, not an empty one (a partially written dump
#     reads like a result);
#   * LISTED and PROCESSED are both counted and asserted equal at the end.
set -u
OUT=${2:?outdir}
CEN=$(cd "$(dirname "$0")" && pwd)/cen111
[ -x "$CEN" ] || { echo "FATAL: no cen111 beside this script"; exit 3; }
mkdir -p "$OUT" || exit 1
: > "$OUT/rows.tsv"
: > "$OUT/skips.txt"
listed=0; processed=0; skipped=0; failed=0
for WD in "$@"; do
  case $WD in "$OUT") continue;; esac
  [ -d "$WD" ] || continue
  while IFS= read -r C; do
    listed=$((listed+1))
    d=$(dirname "$C")
    row=$(basename "$(dirname "$d")")/$(basename "$d")
    O=$d/slang.uhdm
    # rowheads.sh's own extraction, verbatim in spirit: the line reads
    # `surelog: (golden cache hit /path/to/<hash>)`, so the path stops at the
    # closing paren, and a cache DIRECTORY becomes .../golden.uhdm.
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -z "$G" ] && G=$(sed -n 's#.*surelog: *\([^ ()]*\.uhdm\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ ! -s "$O" ] || [ ! -s "$G" ]; then
      echo "SKIP $row o=$O g=$G" >> "$OUT/skips.txt"; skipped=$((skipped+1)); continue
    fi
    gt=$OUT/g.$$.tsv; ot=$OUT/o.$$.tsv
    "$CEN" "$G" > "$gt" 2>/dev/null
    "$CEN" "$O" > "$ot" 2>/dev/null
    if ! tail -1 "$gt" | grep -q '^CENRC 0$' || ! tail -1 "$ot" | grep -q '^CENRC 0$'; then
      echo "CENFAIL $row" >> "$OUT/skips.txt"; failed=$((failed+1)); rm -f "$gt" "$ot"; continue
    fi
    awk -v r="$row" -F'\t' '!/^CENRC/{print "G\t" r "\t" $1 "\t" $2 "\t" $3 "\t" $4}' "$gt" >> "$OUT/rows.tsv"
    awk -v r="$row" -F'\t' '!/^CENRC/{print "O\t" r "\t" $1 "\t" $2 "\t" $3 "\t" $4}' "$ot" >> "$OUT/rows.tsv"
    rm -f "$gt" "$ot"
    processed=$((processed+1))
  done < <(find "$WD" -name cmds.txt | sort)
done
echo "LISTED $listed  PROCESSED $processed  SKIPPED $skipped  CENFAIL $failed"
[ $((processed+skipped+failed)) -eq $listed ] && echo "ACCOUNTING PASS" || echo "ACCOUNTING FAIL"
