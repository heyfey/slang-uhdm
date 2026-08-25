#!/usr/bin/env bash
# r10uvm134 — WIDE BOUNDARY GATE.  MEASUREMENT ONLY (uhdm-cmp is the judge).
#
# Every .sv/.svh under the named directories is compiled by the PRISTINE and
# the PATCHED binary in BOTH views; the two uhdm-dumps are diffed whole
# (workdir-normalised).  A file whose dump moved must be attributable to
# § foreachLoopListStopsAtFirstSelect134 on TWO independent counts:
#
#   1. its ct134cen FOREACH census must have moved too — a dump change with a
#      frozen foreach census is a change OUTSIDE the law's object (BREACH);
#   2. its SOURCE must actually contain the law's syntactic predicate — a
#      foreach whose loop list writes an index select before a dot
#      (`foreach (x[i].y…`) — otherwise the law cannot reach it (BREACH).
#
#   PRI=<pristine> PAT=<patched> CEN=<ct134cen> [WD=<scratch>] bound134.sh <dir> …
#   PRI=… PAT=… CEN=… FILES=<list-file> bound134.sh
#   CTRL=1 asserts the gate FIRES (positive control).
#
# Ops traps this gate pays for (RESUME.md §9 "Boundary gates"):
#   * SUBDIRECTORY arms are compiled too (a top-level glob runs nothing and
#     prints green);
#   * the file list is read on fd 3 and every child gets </dev/null;
#   * scratch is keyed on the arm's RELATIVE path (several trees keep three
#     files all called dut.sv);
#   * PROCESSED is asserted against LISTED;
#   * every rc is recorded (verify_golden.py records rc=139 segfaults as
#     SLANG_REJECT — a crash must never read as "no differences").
set -u
PRI=${PRI:?set PRI=<pristine binary>}
PAT=${PAT:?set PAT=<patched binary>}
CEN=${CEN:?set CEN=<ct134cen binary>}
WD=${WD:-/tmp/r10uvm134_bound}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
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
  # the law's SOURCE predicate: a foreach loop list with an index select
  # written before a dot.
  if grep -qE 'foreach[[:space:]]*\([^)]*\[[^]]*\][[:space:]]*\.' "$f"; then
    pred=YES; else pred=NO; fi
  for view in def elab; do
    o=$WD/$key.$view; mkdir -p "$o"
    if [ "$view" = elab ]; then SUX=--elabuhdm; else SUX=; fi
    ( cd "$(dirname "$f")" && "$PRI" "$(basename "$f")" --single-unit $SUX \
        -o "$o/pris.uhdm" > "$o/pris.log" 2>&1 </dev/null ); rp=$?
    ( cd "$(dirname "$f")" && "$PAT" "$(basename "$f")" --single-unit $SUX \
        -o "$o/pat.uhdm"  > "$o/pat.log"  2>&1 </dev/null ); rq=$?
    echo "rc_pris=$rp rc_pat=$rq pred=$pred" > "$o/rcs"
    if [ "$rp" -ne "$rq" ]; then
      echo "BREACH rc-mismatch $rel $view rc_pris=$rp rc_pat=$rq"; breach=$((breach+1)); rcmis=$((rcmis+1)); continue
    fi
    if [ ! -f "$o/pris.uhdm" ] || [ ! -f "$o/pat.uhdm" ]; then
      norun=$((norun+1)); continue
    fi
    "$DUMP" "$o/pris.uhdm" 2>/dev/null </dev/null | sed "s#$WD/[^ ,]*##g" > "$o/pris.dmp"
    "$DUMP" "$o/pat.uhdm"  2>/dev/null </dev/null | sed "s#$WD/[^ ,]*##g" > "$o/pat.dmp"
    n=$(diff "$o/pris.dmp" "$o/pat.dmp" | grep -c '^[<>]'); true
    if [ "${n:-0}" -eq 0 ]; then continue; fi
    moved=$((moved+1))
    "$CEN" "$o/pris.uhdm" > "$o/pris.cen" 2>/dev/null </dev/null
    "$CEN" "$o/pat.uhdm"  > "$o/pat.cen"  2>/dev/null </dev/null
    cn=$(diff "$o/pris.cen" "$o/pat.cen" | grep -c '^[<>]'); true
    diff "$o/pris.dmp" "$o/pat.dmp" > "$o/dump.diff"
    if [ "${cn:-0}" -eq 0 ]; then
      echo "BREACH dump-moved-census-frozen $rel $view lines=$n"; breach=$((breach+1)); continue
    fi
    if [ "$pred" != YES ]; then
      echo "BREACH no-source-predicate $rel $view lines=$n cen=$cn"; breach=$((breach+1)); continue
    fi
    echo "MOVED $rel $view dumplines=$n cenlines=$cn"
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc MOVED=$moved BREACH=$breach RC-MISMATCH=$rcmis NORUN=$norun"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
if [ "$CTRL" = 1 ]; then
  [ "$moved" -gt 0 ] && { echo "POSITIVE-CONTROL-OK (gate can see: $moved arm-views moved)"; exit 0; }
  echo "POSITIVE-CONTROL-FAILED (gate saw nothing)"; exit 7
fi
[ "$breach" -eq 0 ] && echo "BOUNDARY PASS" || { echo "BOUNDARY FAIL"; exit 8; }
