#!/usr/bin/env bash
# r10uvm196 — THE CORPUS CENSUS DRIVER.  MEASUREMENT ONLY.
#
# Runs ct196cen's `--cen` (golden x ours) over every row of a workdir.  Each
# row's golden is found through THAT ROW'S OWN `cmds.txt`, never guessed from a
# test name (RESUME §9).  Rows whose golden is missing are NAMED, not skipped —
# and every one of them also has no `slang.uhdm`, so nothing of ours can move
# there.
#
# usage: CEN=<ct196cen> ./cen196.sh <workdir> <out file> [jobs]
set -u
CEN=${CEN:?set CEN to the ct196cen binary}
WD=${1:?workdir}
OUT=${2:?out file}
J=${3:-2}
: > "$OUT"
find "$WD" -name slang.uhdm | sort > "$OUT.list"
N=$(wc -l < "$OUT.list")
echo "-- databases listed: $N" >> "$OUT"
run_one() {
  db=$1
  d=$(dirname "$db")
  tag=$(printf '%s' "$db" | sed "s|^$WD/||; s|/slang.uhdm$||")
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$d/cmds.txt" 2>/dev/null | head -1)
  if [ -z "$g" ] || [ ! -f "$g/golden.uhdm" ]; then
    echo "NOGOLDEN $tag"
    echo "RC $tag 0"
    return
  fi
  timeout 900 "$CEN" --cen "$g/golden.uhdm" "$db" "$tag" 2>&1
  echo "RC $tag $?"
}
export -f run_one
export CEN WD
xargs -a "$OUT.list" -P "$J" -I{} bash -c 'run_one "$@"' _ {} >> "$OUT" 2>&1
R=$(grep -c '^RC ' "$OUT" || true)
NG=$(grep -c '^NOGOLDEN ' "$OUT" || true)
F=$(grep -c 'CEN-RESTORE_FAIL' "$OUT" || true)
NZ=$(awk '$1=="RC" && $3!=0' "$OUT" | wc -l)
M=$(grep -c 'PREDICTED-MOVER' "$OUT" || true)
GC=$(awk -F'GOLDEN-ONLY-COUNT=' '/^CENSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
OC=$(awk -F'OURS-ONLY-COUNT=' '/^CENSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
GI=$(awk -F'GOLDEN-ONLY-IMPORTED=' '/^CENSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
OI=$(awk -F'OURS-ONLY-IMPORTED=' '/^CENSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
GO=$(awk -F'GOLDEN-ONLY-OWN=' '/^CENSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
OO=$(awk -F'OURS-ONLY-OWN=' '/^CENSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
AG=$(awk -F'AGREE=' '/^CENSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
echo "-- PROCESSED=$R LISTED=$N NOGOLDEN=$NG RESTORE_FAILS=$F NONZERO_RC=$NZ MOVER_ROWS=$M" >> "$OUT"
echo "-- TOTALS AGREE=$AG GOLDEN-ONLY-IMPORTED=$GI OURS-ONLY-IMPORTED=$OI GOLDEN-ONLY-OWN=$GO OURS-ONLY-OWN=$OO GOLDEN-ONLY-COUNT=$GC OURS-ONLY-COUNT=$OC" >> "$OUT"
tail -2 "$OUT"
