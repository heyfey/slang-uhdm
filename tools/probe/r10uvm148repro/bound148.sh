#!/usr/bin/env bash
# r10uvm148 — WIDE BOUNDARY GATE.  MEASUREMENT ONLY (uhdm-cmp is the judge).
#
# Every .sv/.svh under the named directories is compiled by the PRISTINE and
# the PATCHED binary in BOTH views, TO THE SAME OUTPUT PATH (a database embeds
# the -o path, so two different paths would differ for that reason alone), and
# the two databases are compared by md5 FIRST — a byte-identical database is a
# file the patch did not touch and needs no dump.  Only a file whose database
# MOVED is dumped, censused and attributed, and it must be attributable to
# § tfItemLocalLosesToPkgVar148 on FOUR independent counts:
#
#   1. its ct148cen census must have moved too — a database change with a
#      frozen census is a change OUTSIDE the law's objects (BREACH);
#   2. pred148.py, run on the PRISTINE census ALONE, must NAME at least one
#      cell for that file AND VIEW — a TF-ITEM body local of a package-scope
#      subroutine, bound to that local, whose home package lists the same name,
#      or a fork-nested reference of the same shape.  That is a predicate over
#      the PRISTINE database, not a syntactic proxy (BREACH if it names none);
#   3. this law REBINDS and never mints or removes: the census's ROW SET must be
#      IDENTICAL (same HSPAN|RSPAN|RNAME multiset), every reference must keep
#      its ROLE / PROD / LOC / PKGV / CLSV / MODV / APKGV / FORK, and the ONLY
#      columns allowed to differ are the BINDING ones — BKIND / BSK / BVIS /
#      BOWN / BSPAN.  Anything else is a BREACH;
#   4. every BINDING that moved must have moved ONTO A PACKAGE: BSK goes
#      function|task -> package, never the other way and never to a third kind.
#      (Golden's own direction; the reverse would be this law running backwards.)
#
#   PRI=<pristine> PAT=<patched> CEN=<ct148cen> [WD=<scratch>] bound148.sh <dir> …
#   PRI=… PAT=… CEN=… FILES=<list-file> bound148.sh
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
CEN=${CEN:?set CEN=<ct148cen binary>}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WD=${WD:-/tmp/r10uvm148_bound}
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
    python3 "$HERE/pred148.py" "$o/pris.cen" > "$o/pred.txt" 2>&1
    ncell=$(sed -n 's/.*PREDICTED-CELLS=\([0-9]*\).*/\1/p' "$o/pred.txt" | tail -1)
    nfork=$(sed -n 's/.*PREDICTED-FORK=\([0-9]*\).*/\1/p' "$o/pred.txt" | tail -1)
    "$DUMP" "$o/pris.uhdm" 2>/dev/null </dev/null \
      | sed -e "s#$WD/[^ ,]*##g" -e 's/id:[0-9]*/id:N/g' > "$o/pris.dmp"
    "$DUMP" "$o/pat.uhdm"  2>/dev/null </dev/null \
      | sed -e "s#$WD/[^ ,]*##g" -e 's/id:[0-9]*/id:N/g' > "$o/pat.dmp"
    diff "$o/pris.dmp" "$o/pat.dmp" > "$o/dump.diff"
    dn=$(grep -c '^[<>]' "$o/dump.diff"); true
    if [ "${cn:-0}" -eq 0 ]; then
      echo "BREACH db-moved-census-frozen $rel $view dumplines=$dn"; breach=$((breach+1)); continue
    fi
    if [ "$(( ${ncell:-0} + ${nfork:-0} ))" -eq 0 ]; then
      echo "BREACH no-predicted-cell $rel $view dumplines=$dn cen=$cn"; breach=$((breach+1)); continue
    fi
    # (3) THE ROW SET AND EVERY NON-BINDING COLUMN MUST BE FROZEN.
    badrow=$(diff <(sed -E 's/\|(BKIND|BSK|BVIS|BOWN|BSPAN)=[^|]*//g' "$o/pris.cen" | sort) \
                  <(sed -E 's/\|(BKIND|BSK|BVIS|BOWN|BSPAN)=[^|]*//g' "$o/pat.cen"  | sort) \
             | grep -c '^[<>]'); true
    if [ "${badrow:-0}" -ne 0 ]; then
      echo "BREACH census-nonbinding-column-moved $rel $view lines=$badrow"
      breach=$((breach+1)); continue
    fi
    # (4) EVERY MOVED BINDING MOVED BETWEEN A SUBROUTINE LISTING AND A PACKAGE
    #     LISTING, AND NOWHERE ELSE.  Two directions are legal and they are the
    #     pass's two halves:
    #       function|task -> package   the TF-ITEM local losing to the package;
    #       package -> function|task   the `ParallelBlockStatement` half, where
    #                                  the reference turns out to be EARLY bound
    #                                  and keeps its local -- allowed ONLY on a
    #                                  row the census marks FORK=1.
    #     A move to or from any third kind, or to/from UNBOUND, is a BREACH.
    bad=$(python3 "$HERE/bindmoves148.py" "$o/pris.cen" "$o/pat.cen"); true
    if [ "${bad:-0}" -ne 0 ]; then
      echo "BREACH binding-moved-off-package $rel $view bad=$bad"; breach=$((breach+1)); continue
    fi
    echo "MOVED $rel $view dumplines=$dn cenlines=$cn predcells=$ncell predfork=$nfork"
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc MOVED=$moved BREACH=$breach RC-MISMATCH=$rcmis NORUN=$norun"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
if [ "$CTRL" = 1 ]; then
  [ "$moved" -gt 0 ] && { echo "POSITIVE-CONTROL-OK (gate can see: $moved moved)"; exit 0; }
  echo "POSITIVE-CONTROL-FAILED (gate saw nothing)"; exit 7
fi
[ "$breach" -eq 0 ] && echo "BOUNDARY PASS" || { echo "BOUNDARY FAIL"; exit 8; }
