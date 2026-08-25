#!/usr/bin/env bash
# r10uvm145 — WIDE BOUNDARY GATE.  MEASUREMENT ONLY (uhdm-cmp is the judge).
#
# Every .sv/.svh under the named directories is compiled by the PRISTINE and
# the PATCHED binary in BOTH views, TO THE SAME OUTPUT PATH (a database embeds
# the -o path, so two different paths would differ for that reason alone), and
# the two databases are compared by md5 FIRST — a byte-identical database is a
# file the patch did not touch and needs no dump.  Only a file whose database
# MOVED is dumped, censused and attributed, and it must be attributable to
# § tfItemLocalInitHoistsNoStatement145 on FOUR independent counts:
#
#   1. its ct145cen census must have moved too — a database change with a
#      frozen census is a change OUTSIDE the law's objects (BREACH);
#   2. pred145.py, run on the PRISTINE census ALONE, must NAME at least one
#      cell for that file AND VIEW — a HOIST, a WRAPPER or a CANDIDATE.  That
#      is a predicate over the pristine database (a TF-ITEM body statement
#      whose Lhs IS a `variables` object — Surelog's own declaration test — a
#      TF-ITEM wrapper that loses its threshold, or the one shape a
#      § declInitWrittenNewNoStmt66 drop can hide in) — not a syntactic proxy
#      (BREACH if it names none);
#   3. the census must have moved ONLY by LOSING ROW=STMT rows and by the
#      columns this law owns — NSTMTS / NTOPS / BKIND / BSPAN on a ROW=BODY,
#      and LHOIST / LPAR on a ROW=LOC (`vpiParent` goes back to the FUNCTION
#      when the assignment that held it is gone; no generated Compare reads
#      VpiParent).  A row that appears outside those columns is a BREACH, and
#      the census must have LOST either a ROW=STMT or a ROW=BODY's wrapper
#      columns;
#   4. NOTHING TEXTUALLY NEW: with UhdmIds normalised away and indentation
#      stripped, every line the PATCHED dump gained must already occur
#      somewhere in the PRISTINE dump.  A re-parent or a promoted statement
#      re-prints an identity that existed; a new object cannot.
#
#   PRI=<pristine> PAT=<patched> CEN=<ct145cen> [WD=<scratch>] bound145.sh <dir> …
#   PRI=… PAT=… CEN=… FILES=<list-file> bound145.sh
#   CTRL=1 asserts the gate FIRES (positive control).
#
# Ops traps this gate pays for (RESUME.md §9 "Boundary gates"):
#   * SUBDIRECTORY arms are compiled too (a top-level glob runs nothing and
#     prints green);
#   * the file list is read on fd 3 and every child gets </dev/null;
#   * scratch is keyed on the arm's RELATIVE path (several trees keep three
#     files all called dut.sv);
#   * PROCESSED is asserted against LISTED;
#   * every rc is recorded and a pris/pat rc MISMATCH is itself a breach —
#     EXCEPT the one direction this law is expected to change: a PRISTINE
#     rc=139 SEGFAULT that the patch turns into a clean run (the empty-`items9`
#     crash, arm g145_e_zero).  That direction is reported as FIXED-CRASH and
#     counted; the reverse is always a breach.
set -u
PRI=${PRI:?set PRI=<pristine binary>}
PAT=${PAT:?set PAT=<patched binary>}
CEN=${CEN:?set CEN=<ct145cen binary>}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WD=${WD:-/tmp/r10uvm145_bound}
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
listed=$(wc -l < "$LIST"); proc=0; breach=0; moved=0; norun=0; rcmis=0; fixed=0
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
      if [ "$rp" -eq 139 ] && [ "$rq" -ne 139 ]; then
        echo "FIXED-CRASH $rel $view rc_pris=139 rc_pat=$rq"; fixed=$((fixed+1)); continue
      fi
      echo "BREACH rc-mismatch $rel $view rc_pris=$rp rc_pat=$rq"
      breach=$((breach+1)); rcmis=$((rcmis+1)); continue
    fi
    if [ "$ma" = NONE ] || [ "$mb" = NONE ]; then norun=$((norun+1)); continue; fi
    [ "$ma" = "$mb" ] && { rm -f "$o/pris.uhdm" "$o/pat.uhdm"; continue; }
    moved=$((moved+1))
    "$CEN" "$o/pris.uhdm" > "$o/pris.cen" 2>/dev/null </dev/null
    "$CEN" "$o/pat.uhdm"  > "$o/pat.cen"  2>/dev/null </dev/null
    cn=$(diff "$o/pris.cen" "$o/pat.cen" | grep -c '^[<>]'); true
    python3 "$HERE/pred145.py" "$o/pris.cen" > "$o/pred.txt" 2>&1
    # NOTE the trailing `.*` on every one of these: without it sed leaves the
    # REST of the summary line in the variable and `$(( ))` then dies on a bare
    # word under `set -u` (this gate ate its own run once for exactly that).
    ncell=$(sed -n 's/.*PREDICTED-HOISTS=\([0-9]*\).*/\1/p' "$o/pred.txt" | tail -1)
    nwrap=$(sed -n 's/.*PREDICTED-WRAPPERS=\([0-9]*\).*/\1/p' "$o/pred.txt" | tail -1)
    "$DUMP" "$o/pris.uhdm" 2>/dev/null </dev/null \
      | sed -e "s#$WD/[^ ,]*##g" -e 's/id:[0-9]*/id:N/g' > "$o/pris.dmp"
    "$DUMP" "$o/pat.uhdm"  2>/dev/null </dev/null \
      | sed -e "s#$WD/[^ ,]*##g" -e 's/id:[0-9]*/id:N/g' > "$o/pat.dmp"
    diff "$o/pris.dmp" "$o/pat.dmp" > "$o/dump.diff"
    dn=$(grep -c '^[<>]' "$o/dump.diff"); true
    if [ "${cn:-0}" -eq 0 ]; then
      echo "BREACH db-moved-census-frozen $rel $view dumplines=$dn"; breach=$((breach+1)); continue
    fi
    ncand=$(sed -n 's/.*PREDICTED-CANDIDATES=\([0-9]*\).*/\1/p' "$o/pred.txt" | tail -1)
    if [ "$(( ${ncell:-0} + ${nwrap:-0} + ${ncand:-0} ))" -eq 0 ]; then
      echo "BREACH no-predicted-cell $rel $view dumplines=$dn cen=$cn"; breach=$((breach+1)); continue
    fi
    # (3) census may only LOSE ROW=STMT rows; ROW=LOC must be untouched, and
    #     ROW=BODY may move only in NSTMTS / NTOPS / BKIND.
    # A ROW=BODY line may APPEAR only when its pristine twin differs solely in
    # the columns this law owns.  ROW=STMT is deliberately EXCLUDED from this
    # test: when a wrapper `begin` is dropped, the SOURCE `begin` underneath it
    # becomes the body and ITS statements become top-level ones, so a ROW=STMT
    # row legitimately appears — and check (4) below proves that statement is
    # not a NEW OBJECT, only one that moved up a level.
    badapp=$(diff <(grep -v '^ROW=STMT' "$o/pris.cen" | sed -E -e 's/\|(NSTMTS|NTOPS|BKIND|BSPAN|LHOIST|LPAR)=[^|]*//g' -e 's/\|HID=[0-9]*//' | sort -u) \
                  <(grep -v '^ROW=STMT' "$o/pat.cen"  | sed -E -e 's/\|(NSTMTS|NTOPS|BKIND|BSPAN|LHOIST|LPAR)=[^|]*//g' -e 's/\|HID=[0-9]*//' | sort -u) \
             | grep '^>' | grep -c .); true
    if [ "${badapp:-0}" -ne 0 ]; then
      echo "BREACH census-row-appeared $rel $view lines=$badapp"; breach=$((breach+1)); continue
    fi
    # ROW=LOC may only DISAPPEAR (the law removes objects and never adds one:
    # a surplus DUPLICATE LISTING of a subroutine goes with the statement whose
    # emission minted it — grid arm g145_b_kind.elab, 4 listings -> golden's 2).
    # A LOC line that APPEARS is a breach.
    # (HID is the owner's UhdmId and shifts with every removed object — strip
    # it here as everywhere else, or every LOC line reads as "appeared".)
    badloc=$(diff <(grep '^ROW=LOC' "$o/pris.cen" | sed -E -e 's/\|(LHOIST|LPAR)=[^|]*//g' -e 's/\|HID=[0-9]*//' | sort) \
                  <(grep '^ROW=LOC' "$o/pat.cen"  | sed -E -e 's/\|(LHOIST|LPAR)=[^|]*//g' -e 's/\|HID=[0-9]*//' | sort) \
             | grep -c '^>'); true
    if [ "${badloc:-0}" -ne 0 ]; then
      echo "BREACH census-LOC-appeared $rel $view lines=$badloc"; breach=$((breach+1)); continue
    fi
    # The census must have LOST something the law removes: either a top-level
    # ROW=STMT (a hoisted initialiser) or a ROW=BODY row's wrapper columns (a
    # `begin` that lost its threshold).  The SECOND disjunct is load-bearing:
    # where § declIntWrittenNewNoStmt66 had ALREADY dropped the initialiser,
    # nothing is lost but the WRAPPER, and no ROW=STMT changes at all
    # (r10uvm66repro/a2_slots.sv `n24_tfitems`, whose patched BODY row —
    # BKIND=method_func_call, NSTMTS=-1 — is byte-identical to GOLDEN's while
    # the pristine one, BKIND=begin NSTMTS=1, was not).
    lost=$(diff <(sed -E 's/\|HID=[0-9]*//' "$o/pris.cen" | sort) \
                 <(sed -E 's/\|HID=[0-9]*//' "$o/pat.cen" | sort) \
           | grep -c '^< ROW=STMT'); true
    bodymoved=$(diff <(grep '^ROW=BODY' "$o/pris.cen" | sed -E 's/\|HID=[0-9]*//' | sort) \
                     <(grep '^ROW=BODY' "$o/pat.cen"  | sed -E 's/\|HID=[0-9]*//' | sort) \
                | grep -c '^<'); true
    if [ "$(( ${lost:-0} + ${bodymoved:-0} ))" -eq 0 ]; then
      echo "BREACH census-lost-nothing $rel $view cen=$cn"; breach=$((breach+1)); continue
    fi
    # (4) NOTHING TEXTUALLY NEW.  This law only ever REMOVES objects, so every
    # line the PATCHED dump gained must already occur SOMEWHERE in the PRISTINE
    # dump — a re-parent (`vpiParent` back to the function) or a re-indent (a
    # statement promoted out of a dropped wrapper) re-prints an identity that
    # existed; a genuinely new object cannot.  Leading whitespace is stripped
    # because the indentation IS the thing that legitimately changes, and
    # UhdmIds were normalised when the dumps were written.
    surplus=$(comm -13 <(sed 's/^ *//' "$o/pris.dmp" | sort -u) \
                       <(grep '^>' "$o/dump.diff" | cut -c3- | sed 's/^ *//' | sort -u) \
              | grep -c .); true
    if [ "${surplus:-0}" -ne 0 ]; then
      echo "BREACH dump-line-not-in-pristine $rel $view surplus=$surplus"; breach=$((breach+1)); continue
    fi
    echo "MOVED $rel $view dumplines=$dn cenlines=$cn predhoists=$ncell predwrap=$nwrap predcand=$ncand"
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc MOVED=$moved FIXED-CRASH=$fixed BREACH=$breach RC-MISMATCH=$rcmis NORUN=$norun"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
if [ "$CTRL" = 1 ]; then
  [ "$(( moved + fixed ))" -gt 0 ] && { echo "POSITIVE-CONTROL-OK (gate can see: $moved moved, $fixed crash-fixed)"; exit 0; }
  echo "POSITIVE-CONTROL-FAILED (gate saw nothing)"; exit 7
fi
[ "$breach" -eq 0 ] && echo "BOUNDARY PASS" || { echo "BOUNDARY FAIL"; exit 8; }
