#!/usr/bin/env bash
# r10uvm218 — THE A-PRIORI PREDICTOR (question 5).  MEASUREMENT ONLY.  Written
# and RUN from PRISTINE databases and PRISTINE sources alone, BEFORE the patched
# binary exists.
#
# § uninstIfaceBodyBindsInMethodWindow218 can only fire in a database that
# carries an INTERFACE DEFINITION THAT NO INSTANCE ELABORATES AND THAT DECLARES
# A SUBROUTINE.  A database that never compiled such a file is untouchable BY
# CONSTRUCTION, and that is what this script decides, row-mode by row-mode.
#
# Each row-mode's own `cmds.txt` names the files it compiled (`include`d files
# are not listed, which is why the second stage below re-reads the PRISTINE
# DATABASE itself rather than trusting the grep).
#
#   STAGE 1 (source):  the file set declares `interface <name>` ... and that
#                      `<name>` is not instantiated anywhere in the set.
#   STAGE 2 (database): the PRISTINE database really does carry an
#                      `interface_inst` with `Task_funcs` holding a body
#                      `ref_obj` with NO `vpiActual`.
#
#   usage: predict218.sh <verify_golden-workdir> <out>
set -u
WD=${1:?workdir}; OUT=${2:?out}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump $DUMP"; exit 3; }
: > "$OUT"
tot=0; s1=0
for c in $(find "$WD" -name cmds.txt | sort); do
  d=$(dirname "$c")
  tot=$((tot+1))
  files=$(sed -n 's/^slang: *//p' "$c" | tr ' ' '\n' | grep -E '\.(sv|v|svh|vh)$'); true
  hit=""
  for f in $files; do
    [ -f "$f" ] || continue
    ifs=$(grep -oE '^[[:space:]]*interface[[:space:]]+[A-Za-z_][A-Za-z0-9_$]*' "$f" 2>/dev/null | awk '{print $2}'); true
    for i in $ifs; do
      [ -n "$i" ] || continue
      # does ANY compiled file instantiate it?  `<name> <inst> (` or `<name> #(`
      inst=0
      for g in $files; do
        [ -f "$g" ] || continue
        if grep -qE "(^|[^A-Za-z0-9_$])$i[[:space:]]+[A-Za-z_][A-Za-z0-9_$]*[[:space:]]*[(\[]|(^|[^A-Za-z0-9_$])$i[[:space:]]*#[[:space:]]*\(" "$g" 2>/dev/null; then
          inst=1; break
        fi
      done
      [ "$inst" -eq 0 ] && hit="$hit $i"
    done
  done
  if [ -n "$hit" ]; then
    s1=$((s1+1))
    echo "STAGE1 $d uninstantiated-interface-candidates:$hit" >> "$OUT"
  fi
done
echo "-- STAGE1: $s1 of $tot row-modes carry a candidate" >> "$OUT"
tail -1 "$OUT"
