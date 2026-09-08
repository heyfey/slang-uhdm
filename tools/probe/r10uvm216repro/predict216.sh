#!/usr/bin/env bash
# r10uvm216 — THE A-PRIORI CORPUS PREDICTOR.  MEASUREMENT ONLY.
#
# Run against PRISTINE databases and PRISTINE sources alone, BEFORE the patched
# binary exists, so the mover set is named a priori and never read off the
# result.
#
# § dpiExportListedAtExportItem216 can only touch a database that actually
# COMPILED a file carrying an `export "DPI-C"` item.  `cmds.txt` does not list
# `include`d files, so the file set is taken from the DATABASE itself
# (`ct216cen --files` = every distinct `VpiFile` in the arena) and grepped.  A
# row whose database names no such file is UNTOUCHABLE by construction.
#
# For every row that does compile one it reports, from the row's own PRISTINE
# `slang.uhdm`:
#   EXPMARK=<n>  distinct task_func entries already carrying
#                vpiAccessType=vpiDPIExportAcc
# which separates the two failure modes in advance:
#   * an export item present and EXPMARK=0  -> the FLAGS half (grid arm D:
#     a never-instantiated interface definition, whose export directives slang
#     never resolves);
#   * an export item present and EXPMARK>0  -> the POSITION half may still fire.
#
# It NEVER dispatches a test; it reads databases and sources only.
# `scrub216.sh` redacts the fenced names from the output afterwards.
#
# usage: CEN=<ct216cen> ./predict216.sh <sweep-workdir> <out>
set -u
CEN=${CEN:?path to ct216cen}
WD=${1:?sweep workdir}; OUT=${2:?out}
[ -x "$CEN" ] || { echo "FATAL: no ct216cen $CEN"; exit 3; }
[ -d "$WD" ]  || { echo "FATAL: no workdir $WD"; exit 3; }
: > "$OUT"
CACHE=$(mktemp -d "${TMPDIR:-/tmp}/r10uvm216_pred.XXXXXX") || exit 1
trap 'rm -rf "$CACHE"' EXIT
rows=0; nodb=0; hits=0
while IFS= read -r db; do
  d=$(dirname "$db")
  rows=$((rows+1))
  row=$(basename "$d"); mode=$(basename "$(dirname "$d")")
  files=$("$CEN" "$db" --files 2>/dev/null)
  [ -n "$files" ] || { nodb=$((nodb+1)); continue; }
  n=0
  for f in $files; do
    [ -f "$f" ] || continue
    # memoise the per-FILE answer: the corpus shares thousands of headers
    k=$CACHE/$(echo "$f" | tr '/' '_')
    if [ ! -f "$k" ]; then
      if grep -q -E 'export[[:space:]]+"DPI' "$f" 2>/dev/null; then
        echo 1 > "$k"
      else
        echo 0 > "$k"
      fi
    fi
    [ "$(cat "$k")" = 1 ] && n=$((n+1))
  done
  [ "$n" -gt 0 ] || continue
  hits=$((hits+1))
  marks=$("$CEN" "$db" --dpi 2>/dev/null | grep -c 'MEM|.*acc=EXPORT'); true
  echo "ROW $row $mode EXPORTFILES=$n EXPMARK=$marks" >> "$OUT"
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- DATABASES=$rows UNREADABLE=$nodb WITH-EXPORT-ITEM=$hits" >> "$OUT"
tail -1 "$OUT"
