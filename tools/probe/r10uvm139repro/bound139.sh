#!/usr/bin/env bash
# r10uvm139 — WIDE BOUNDARY GATE.  MEASUREMENT ONLY (uhdm-cmp is the judge).
#
# Every .sv/.svh under the named directories is compiled by the PRISTINE and
# the PATCHED binary in BOTH views, TO THE SAME OUTPUT PATH (a database embeds
# the -o path, so two different paths would differ for that reason alone), and
# the two databases are compared by md5 FIRST — a byte-identical database is a
# file the patch did not touch and needs no dump.  Only a file whose database
# MOVED is dumped, censused and attributed, and it must be attributable to
# § tfItemLocalAutomaticIsNotWrittenStatic139 on TWO independent counts:
#
#   1. its ct139cen VARIABLE census must have moved too — a database change with
#      a frozen variable census is a change OUTSIDE the law's object (BREACH);
#   2. the PREDICTOR binary (the PRISTINE emitter plus one inert `fprintf`) must
#      name at least one cell for that file AND VIEW — this is an EXACT
#      predicate, not a syntactic proxy: it is the law's own decision, evaluated
#      on the old code path (BREACH if it names none);
#   3. every census line that moved must be an AUTO= flip and nothing else
#      (BREACH otherwise).
#
#   PRI=<pristine> PAT=<patched> PRED=<predictor> CEN=<ct139cen> \
#       [WD=<scratch>] bound139.sh <dir> …
#   PRI=… PAT=… PRED=… CEN=… FILES=<list-file> bound139.sh
#   CTRL=1 asserts the gate FIRES (positive control).
#
# Ops traps this gate pays for (RESUME.md §9 "Boundary gates"):
#   * SUBDIRECTORY arms are compiled too (a top-level glob runs nothing and
#     prints green);
#   * the file list is read on fd 3 and every child gets </dev/null;
#   * scratch is keyed on the arm's RELATIVE path (several trees keep three
#     files all called dut.sv);
#   * PROCESSED is asserted against LISTED;
#   * every rc is recorded and a pris/pat rc MISMATCH is itself a breach
#     (verify_golden.py records rc=139 segfaults as SLANG_REJECT — a crash must
#     never read as "no differences").
set -u
PRI=${PRI:?set PRI=<pristine binary>}
PAT=${PAT:?set PAT=<patched binary>}
PRED=${PRED:?set PRED=<predictor binary>}
CEN=${CEN:?set CEN=<ct139cen binary>}
WD=${WD:-/tmp/r10uvm139_bound}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CTRL=${CTRL:-0}
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/files.txt
: > "$LIST"
if [ -n "${FILES:-}" ]; then
  sort -u "$FILES" > "$LIST"
else
  for root in "$@"; do
    [ -d "$root" ] || { echo "FATAL: no dir $root"; exit 3; }
    ( cd "$root" && find . \( -name '*.sv' -o -name '*.svh' \) | sort ) \
      | sed "s#^\./#$root/#" >> "$LIST"
  done
  sort -u -o "$LIST" "$LIST"
fi
listed=$(wc -l < "$LIST"); proc=0; breach=0; moved=0; norun=0; rcmis=0
exec 3< "$LIST"
while IFS= read -r f <&3; do
  rel=${f#./}; rel=${rel#/}; key=${rel//\//__}
  for view in def elab; do
    o=$WD/$key.$view; mkdir -p "$o"
    if [ "$view" = elab ]; then SUX=--elabuhdm; else SUX=; fi
    db=$o/db.uhdm
    rm -f "$db"
    ( cd "$(dirname "$f")" && "$PRI" "$(basename "$f")" --single-unit $SUX \
        -o "$db" > "$o/pris.log" 2>&1 </dev/null ); rp=$?
    [ -f "$db" ] && { mv "$db" "$o/pris.uhdm"; ma=$(md5sum < "$o/pris.uhdm"); } || ma=NONE
    ( cd "$(dirname "$f")" && "$PAT" "$(basename "$f")" --single-unit $SUX \
        -o "$db" > "$o/pat.log" 2>&1 </dev/null ); rq=$?
    [ -f "$db" ] && { mv "$db" "$o/pat.uhdm"; mb=$(md5sum < "$o/pat.uhdm"); } || mb=NONE
    echo "rc_pris=$rp rc_pat=$rq md5_pris=$ma md5_pat=$mb" > "$o/rcs"
    if [ "$rp" -ne "$rq" ]; then
      echo "BREACH rc-mismatch $rel $view rc_pris=$rp rc_pat=$rq"
      breach=$((breach+1)); rcmis=$((rcmis+1)); continue
    fi
    if [ "$ma" = NONE ] || [ "$mb" = NONE ]; then norun=$((norun+1)); continue; fi
    [ "$ma" = "$mb" ] && { rm -f "$o/pris.uhdm" "$o/pat.uhdm"; continue; }
    moved=$((moved+1))
    ( cd "$(dirname "$f")" && PRED139="$o/pred.txt" "$PRED" "$(basename "$f")" \
        --single-unit $SUX -o "$o/pred.uhdm" > "$o/pred.log" 2>&1 </dev/null )
    echo "rc_pred=$?" >> "$o/rcs"
    ncell=$(grep -c '^PRED139|' "$o/pred.txt" 2>/dev/null); true
    "$CEN" "$o/pris.uhdm" > "$o/pris.cen" 2>/dev/null </dev/null
    "$CEN" "$o/pat.uhdm"  > "$o/pat.cen"  2>/dev/null </dev/null
    cn=$(diff "$o/pris.cen" "$o/pat.cen" | grep -c '^[<>]'); true
    "$DUMP" "$o/pris.uhdm" 2>/dev/null </dev/null | sed "s#$WD/[^ ,]*##g" > "$o/pris.dmp"
    "$DUMP" "$o/pat.uhdm"  2>/dev/null </dev/null | sed "s#$WD/[^ ,]*##g" > "$o/pat.dmp"
    diff "$o/pris.dmp" "$o/pat.dmp" > "$o/dump.diff"
    dn=$(grep -c '^[<>]' "$o/dump.diff"); true
    if [ "${cn:-0}" -eq 0 ]; then
      echo "BREACH db-moved-census-frozen $rel $view dumplines=$dn"; breach=$((breach+1)); continue
    fi
    if [ "${ncell:-0}" -eq 0 ]; then
      echo "BREACH no-predicted-cell $rel $view dumplines=$dn cen=$cn"; breach=$((breach+1)); continue
    fi
    # every moved census line must differ ONLY in the AUTO= field
    paste -d'\n' /dev/null /dev/null >/dev/null
    other=$(diff <(sed 's/^AUTO=[01]|//' "$o/pris.cen") \
                 <(sed 's/^AUTO=[01]|//' "$o/pat.cen") | grep -c '^[<>]'); true
    if [ "${other:-0}" -ne 0 ]; then
      echo "BREACH census-moved-outside-AUTO $rel $view lines=$other"; breach=$((breach+1)); continue
    fi
    # the whole DUMP diff must be vpiAutomatic lines only
    dother=$(grep '^[<>]' "$o/dump.diff" | grep -vc 'vpiAutomatic'); true
    if [ "${dother:-0}" -ne 0 ]; then
      echo "BREACH dump-moved-outside-vpiAutomatic $rel $view lines=$dother"; breach=$((breach+1)); continue
    fi
    echo "MOVED $rel $view dumplines=$dn cenlines=$cn predcells=$ncell"
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc MOVED=$moved BREACH=$breach RC-MISMATCH=$rcmis NORUN=$norun"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
if [ "$CTRL" = 1 ]; then
  [ "$moved" -gt 0 ] && { echo "POSITIVE-CONTROL-OK (gate can see: $moved file-views moved)"; exit 0; }
  echo "POSITIVE-CONTROL-FAILED (gate saw nothing)"; exit 7
fi
[ "$breach" -eq 0 ] && echo "BOUNDARY PASS" || { echo "BOUNDARY FAIL"; exit 8; }
