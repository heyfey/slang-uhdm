#!/usr/bin/env bash
# r10uvm201 — THE CORPUS CENSUS / PREDICTION DRIVER.  MEASUREMENT ONLY.
#
# Runs ct201cen over every database of a verify_golden workdir.  Each row's
# golden is read out of THAT ROW'S OWN cmds.txt, never guessed from a test name
# (RESUME §9).  Rows whose golden is missing are NAMED, not skipped, and the
# `--pred` mode runs on them anyway (it needs no golden), so a database our
# binary produced can never fall out of the accounting unseen.
#
# usage: CEN=<ct201cen> ./cen201.sh --cen|--pred <workdir> <out file> [jobs]
set -u
CEN=${CEN:?set CEN to the ct201cen binary}
MODE=${1:?--cen or --pred}
WD=${2:?workdir}
OUT=${3:?out file}
J=${4:-2}
: > "$OUT"
find "$WD" -name slang.uhdm | sort > "$OUT.list"
N=$(wc -l < "$OUT.list")
echo "-- databases listed: $N  mode: $MODE" >> "$OUT"
run_one() {
  db=$1
  d=$(dirname "$db")
  tag=$(printf '%s' "$db" | sed "s|^$WD/||; s|/slang.uhdm$||")
  if [ "$MODE" = "--pred" ]; then
    timeout 900 "$CEN" --pred "$db" "$tag" 2>&1
    echo "RC $tag $?"
    return
  fi
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$d/cmds.txt" 2>/dev/null | head -1)
  if [ -z "$g" ] || [ ! -f "$g/golden.uhdm" ]; then
    echo "NOGOLDEN $tag"; echo "RC $tag 0"; return
  fi
  timeout 900 "$CEN" --cen "$g/golden.uhdm" "$db" "$tag" 2>&1
  echo "RC $tag $?"
}
export -f run_one
export CEN WD MODE
xargs -a "$OUT.list" -P "$J" -I{} bash -c 'run_one "$@"' _ {} >> "$OUT" 2>&1
R=$(grep -c '^RC ' "$OUT" || true)
NG=$(grep -c '^NOGOLDEN ' "$OUT" || true)
F=$(grep -c 'RESTORE_FAIL' "$OUT" || true)
NZ=$(awk '$1=="RC" && $3!=0' "$OUT" | wc -l)
M=$(grep -c 'PREDICTED-MOVER' "$OUT" || true)
AG=$(awk -F'AGREE=' '/^CENSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
SD=$(awk -F'TS-DIFF=' '/^CENSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
GO=$(awk -F'ONLY-GOLDEN=' '/^CENSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
OO=$(awk -F'ONLY-OURS=' '/^CENSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
ZC=$(awk -F'RHSGAP=' '/^PREDSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
ZL=$(awk -F'LHSGAP=' '/^PREDSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
CE=$(awk -F' cells=' '/^PREDSUM/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")
echo "-- PROCESSED=$R LISTED=$N NOGOLDEN=$NG RESTORE_FAILS=$F NONZERO_RC=$NZ MOVER_ROWS=$M" >> "$OUT"
echo "-- TOTALS AGREE=$AG TS-DIFF=$SD ONLY-GOLDEN=$GO ONLY-OURS=$OO PRED-CELLS=$CE PRED-RHSGAP=$ZC PRED-LHSGAP=$ZL" >> "$OUT"
tail -2 "$OUT"
