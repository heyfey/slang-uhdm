#!/usr/bin/env bash
# r10buvm14repro/cenall14.sh — the CORPUS-WIDE hier_path census, golden vs ours,
# over EVERY database of one verify_golden workdir.
#
#   usage: cenall14.sh <workdir root> <tag> [--only-mc]
#
# Each test's GOLDEN is read out of its OWN cmds.txt (never guessed), so this
# cannot silently compare against the wrong golden.
#
# GUARDS (each an ops trap this campaign has paid for):
#   * `SKIP` (no golden, no database, or a restore failure) is COUNTED and
#     PRINTED, never hidden — a driver that reaches nothing must not read as
#     perfection.
#   * the number of `==` headers is ASSERTED against the number of joins
#     actually reported (buvm12's lost-577-joins trap).
#   * the golden cache DIRECTORY is turned into `.../golden.uhdm`; handing a
#     directory to the census compares nothing.
#
# WHY A CORPUS-WIDE CENSUS IS A GATE AND NOT A GARNISH: buvm13's one-row census
# read DISAGREE 0 while the corpus said 16 cells had gone BACKWARDS.  A per-row
# reading cannot see an over-fire that lives in another row.
set -u
W=${1:?workdir root}
TAG=${2:?tag}
shift 2
CEN=${CEN:-/tmp/r10buvm14cen}
JOIN=$(cd "$(dirname "$0")" && pwd)/cenjoin14.py
[ -x "$CEN" ] || { echo "FATAL: no census tool at $CEN"; exit 3; }
OUT=/tmp/r10buvm14_cenall_$TAG
mkdir -p "$OUT"
nh=0; nj=0; nskip=0
: > "$OUT/rows.txt"
while read -r c; do
  d=$(dirname "$c")
  O=$d/slang.uhdm
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$c" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
    nskip=$((nskip+1)); continue
  fi
  nh=$((nh+1))
  "$CEN" "$G" G > "$OUT/g.txt" 2>/dev/null
  "$CEN" "$O" O > "$OUT/o.txt" 2>/dev/null
  if grep -q '^RESTORE_FAIL' "$OUT/g.txt" "$OUT/o.txt"; then
    nskip=$((nskip+1)); nh=$((nh-1)); continue
  fi
  echo "== $d" >> "$OUT/rows.txt"
  python3 "$JOIN" "$OUT/g.txt" "$OUT/o.txt" "$@" | sed 's/^/   /' >> "$OUT/rows.txt"
  nj=$((nj+1))
done < <(find "$W" -name cmds.txt | sort)
hdr=$(grep -c '^== ' "$OUT/rows.txt" || true)
rep=$(grep -c '^   AGREE=' "$OUT/rows.txt" || true)
echo "workdir=$W tag=$TAG  joined=$nj  SKIP=$nskip  headers=$hdr  joins-reported=$rep"
[ "$hdr" = "$rep" ] || { echo "FATAL: $hdr headers but $rep joins reported -- joins were LOST"; exit 5; }
awk '/^   AGREE=/{
  for (i=1;i<=NF;i++) { split($i,a,"="); t[a[1]]+=a[2] } }
  END { printf "TOTALS %s: ", ENVIRON["TAG"];
        printf "AGREE=%d DISAGREE=%d ARITY-DIFF=%d MISSING-OURS=%d EXTRA-OURS=%d\n",
               t["AGREE"], t["DISAGREE"], t["ARITY-DIFF"], t["MISSING-OURS"], t["EXTRA-OURS"] }' \
  TAG="$TAG" "$OUT/rows.txt"
echo "rows: $OUT/rows.txt"
