#!/usr/bin/env bash
# r10uvm183 — THE A-PRIORI MOVER PREDICTION, over a whole PRISTINE sweep.
# MEASUREMENT ONLY.  It never opens the patched binary or a patched database:
# it reads each row's OWN `cmds.txt` for the golden cache path, dumps the
# `ct183cen --fe` foreach census of the GOLDEN and of the PRISTINE database,
# and `predict183.py` names the rows this law must move.
#
#   PRIS=<pristine workdir> CT183CEN=<ct183cen> ./predict183.sh <outdir> [jobs]
set -u
OUT=${1:?outdir}
JOBS=${2:-2}
PRIS=${PRIS:?set PRIS to the pristine sweep workdir}
CEN=${CT183CEN:?set CT183CEN to the built ct183cen}
mkdir -p "$OUT"
: > "$OUT/rows.txt"
: > "$OUT/work.txt"
for mode in default testflags; do
  [ -d "$PRIS/$mode" ] || continue
  for d in "$PRIS/$mode"/*/; do
    row=$(basename "$d"); name=${row%-*}
    [ -f "$d/slang.uhdm" ] || continue
    g=$(tr ' ' '\n' < "$d/cmds.txt" | grep -o '/home/[^ )]*slang-uhdm-goldens/[0-9a-f]*' | head -1)
    [ -n "$g" ] && [ -f "$g/golden.uhdm" ] || continue
    printf '%s\t%s\t%s\t%s\n' "$mode" "$name" "$g/golden.uhdm" "$d/slang.uhdm" >> "$OUT/work.txt"
    echo "$mode $name" >> "$OUT/rows.txt"
  done
done
echo "COMPARABLE_ROWS=$(wc -l < "$OUT/work.txt")"
export CEN OUT
< "$OUT/work.txt" xargs -P "$JOBS" -d '\n' -I{} bash -c '
  IFS=$'"'"'\t'"'"' read -r mode name g o <<< "{}"
  "$CEN" "$g" --fe > "$OUT/$mode.$name.golden.tsv" 2>&1; rcg=$?
  "$CEN" "$o" --fe > "$OUT/$mode.$name.pris.tsv"   2>&1; rco=$?
  echo "$mode/$name golden_rc=$rcg pris_rc=$rco" >> "$OUT/rc.txt"
'
echo "DUMPED=$(wc -l < "$OUT/rc.txt")"
grep -cv 'golden_rc=0 pris_rc=0' "$OUT/rc.txt" && echo "NONZERO_RC_ROWS above" || true
