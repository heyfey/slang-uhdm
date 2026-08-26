#!/usr/bin/env bash
# r10uvm151 — WIDE BOUNDARY GATE.  MEASUREMENT ONLY (uhdm-cmp is the judge).
#
# Every .sv/.svh under the named directories is compiled by the PRISTINE and
# the PATCHED binary in BOTH views, TO THE SAME OUTPUT PATH (a database embeds
# the -o path, so two different paths would differ for that reason alone), and
# the two databases are compared by md5 FIRST — a byte-identical database is a
# file the patch did not touch and needs no dump.  Only a file whose database
# MOVED is dumped, censused and attributed, and it must be attributable to
# § stmtBuiltinBodyIsBareRecvCall151 on THREE independent counts (attr151.py):
#
#   1. its ct151cen census must have moved too — a database change with a
#      frozen census is a change OUTSIDE the law's objects (BREACH);
#   2. CENSUS half: every differing census row is one leg of a FLIP at a shared
#      (FILE, ANCH) — pristine `method_func_call(<method>){prefix <recv>}`,
#      patched bare `func_call(<recv>)` with no prefix, no arguments, no
#      `vpiWith` and no `vpiFunction` — and the row count at every anchor is
#      unchanged.  A row that appeared or vanished, or any other column move,
#      is a BREACH;
#   3. DUMP half: every ADDED line of the whole-dump diff (weakly-referenced
#      TAIL cut off — RESUME.md §9) is the new `func_call`'s header or its
#      `|vpiName:`, and every REMOVED line belongs to the `method_func_call`
#      it replaced or to that call's `vpiPrefix` sub-tree.  Any other line is a
#      BREACH.
#
#   PRI=<pristine> PAT=<patched> CEN=<ct151cen> [WD=<scratch>] bound151.sh <dir> …
#   PRI=… PAT=… CEN=… FILES=<list-file> bound151.sh
#   CTRL=1 asserts the gate FIRES (positive control).
#
# Ops traps this gate pays for (RESUME.md §9 "Boundary gates"):
#   * SUBDIRECTORY arms are compiled too (a top-level glob runs nothing and
#     prints green);
#   * the file list is read on fd 3 and every child gets </dev/null;
#   * scratch is keyed on the arm's RELATIVE path (several trees keep three
#     files all called dut.sv);
#   * PROCESSED is asserted against LISTED;
#   * every rc is recorded and a pris/pat rc MISMATCH is itself a breach.
set -u
PRI=${PRI:?set PRI=<pristine binary>}
PAT=${PAT:?set PAT=<patched binary>}
CEN=${CEN:?set CEN=<ct151cen binary>}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WD=${WD:-/tmp/r10uvm151_bound}
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
    "$CEN" "$o/pris.uhdm" > "$o/pris.cen" 2>/dev/null </dev/null
    "$CEN" "$o/pat.uhdm"  > "$o/pat.cen"  2>/dev/null </dev/null
    cn=$(diff "$o/pris.cen" "$o/pat.cen" | grep -c '^[<>]'); true
    for w in pris pat; do
      "$DUMP" "$o/$w.uhdm" 2>/dev/null </dev/null \
        | awk 'BEGIN{d=1} /^\\_weaklyReferenced:/{d=0} d==1{print}' \
        | sed -e "s#$WD/[^ ,]*##g" -e 's/id:[0-9]*/id:N/g' > "$o/$w.dmp"
    done
    dn=$(diff "$o/pris.dmp" "$o/pat.dmp" | grep -c '^[<>]'); true
    if [ "${cn:-0}" -eq 0 ]; then
      echo "BREACH db-moved-census-frozen $rel $view dumplines=$dn"; breach=$((breach+1)); continue
    fi
    at=$(python3 "$HERE/attr151.py" "$o/pris.cen" "$o/pat.cen" \
                                    "$o/pris.dmp" "$o/pat.dmp"); arc=$?
    nf=$(sed -n 's/.*FLIPS=\([0-9]*\).*/\1/p' <<< "$at")
    if [ "$arc" -ne 0 ] || [ "${nf:-0}" -eq 0 ]; then
      echo "BREACH not-this-law $rel $view $at dumplines=$dn cen=$cn"
      breach=$((breach+1)); continue
    fi
    echo "MOVED $rel $view $at dumplines=$dn cenlines=$cn"
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc MOVED=$moved BREACH=$breach RC-MISMATCH=$rcmis NORUN=$norun"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
# THE NORUN ASSERT.  A file list built with the wrong prefix makes every `cd`
# fail, every database absent and every file-view NORUN -- and the gate then
# prints MOVED=0 BREACH=0 and reads GREEN while having compiled nothing.  That
# is exactly RESUME.md §9's "a top-level glob ran nothing and printed green",
# and it happened once on this pass's own first run.  A gate whose NORUN
# swallows the whole list is a broken gate, not a clean one.
if [ "$norun" -ge "$((listed * 2))" ]; then
  echo "NORUN-ASSERT-FAILED (nothing compiled: NORUN=$norun of $((listed*2)) file-views)"
  exit 5
fi
echo "NORUN-ASSERT-OK ($norun of $((listed*2)) file-views produced no database)"
if [ "$CTRL" = 1 ]; then
  [ "$moved" -gt 0 ] && { echo "POSITIVE-CONTROL-OK (gate can see: $moved moved)"; exit 0; }
  echo "POSITIVE-CONTROL-FAILED (gate saw nothing)"; exit 7
fi
[ "$breach" -eq 0 ] && echo "BOUNDARY PASS" || { echo "BOUNDARY FAIL"; exit 8; }
