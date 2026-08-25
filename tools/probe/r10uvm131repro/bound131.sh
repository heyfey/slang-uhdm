#!/usr/bin/env bash
# r10uvm131 — WIDE BOUNDARY GATE.  MEASUREMENT ONLY (uhdm-cmp is the judge).
#
# Every .sv under the arm tree AND under the named foreign directories is
# compiled by the PRISTINE and the PATCHED binary in BOTH views; the two
# uhdm-dumps are diffed whole (workdir-normalised) and EVERY differing line
# must be one the law claims: a fork_stmt / named_fork header line, a
# vpiJoinType line, or a vpiEndLabel line under a fork.  Anything else is a
# BOUNDARY BREACH.
#
#   PRI=<pristine> PAT=<patched> [WD=<scratch>] bound131.sh <dir> [<dir> ...]
#   PRI=… PAT=… FILES=<list-file> bound131.sh          (explicit file list)
#
# Ops traps this gate pays for (RESUME.md §9 "Boundary gates"):
#   * SUBDIRECTORY arms are compiled too (a top-level glob runs nothing and
#     prints green);
#   * the file list is read on fd 3 and every child gets </dev/null;
#   * scratch is keyed on the arm's RELATIVE path (several trees keep three
#     files all called dut.sv);
#   * PROCESSED is asserted against LISTED;
#   * every rc is recorded (verify_golden.py records rc=139 segfaults as
#     SLANG_REJECT — a crash must never read as "no differences");
#   * a POSITIVE CONTROL (a deliberately moved cell) proves the gate can see:
#     run with CTRL=1 to assert the gate FIRES on the arm tree.
set -u
PRI=${PRI:?set PRI=<pristine binary>}
PAT=${PAT:?set PAT=<patched binary>}
WD=${WD:-/tmp/r10uvm131_bound}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CTRL=${CTRL:-0}
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/files.txt
: > "$LIST"
if [ -n "${FILES:-}" ]; then
  # explicit list: paths must already be absolute or relative to CWD
  sort -u "$FILES" > "$LIST"
else
  for root in "$@"; do
    [ -d "$root" ] || { echo "FATAL: no dir $root"; exit 3; }
    ( cd "$root" && find . \( -name '*.sv' -o -name '*.svh' \) | sort ) \
      | sed "s#^\./#$root/#" >> "$LIST"
  done
fi
listed=$(wc -l < "$LIST"); proc=0; breach=0; moved=0; norun=0
exec 3< "$LIST"
while IFS= read -r f <&3; do
  rel=${f#./}; rel=${rel#/}; key=${rel//\//__}
  for view in def elab; do
    o=$WD/$key.$view; mkdir -p "$o"
    if [ "$view" = elab ]; then SUX=--elabuhdm; else SUX=; fi
    ( cd "$(dirname "$f")" && "$PRI" "$(basename "$f")" --single-unit $SUX \
        -o "$o/pris.uhdm" > "$o/pris.log" 2>&1 </dev/null ); rp=$?
    ( cd "$(dirname "$f")" && "$PAT" "$(basename "$f")" --single-unit $SUX \
        -o "$o/pat.uhdm"  > "$o/pat.log"  2>&1 </dev/null ); rq=$?
    echo "rc_pris=$rp rc_pat=$rq" > "$o/rcs"
    if [ "$rp" -ne "$rq" ]; then
      echo "BREACH rc-mismatch $rel $view rc_pris=$rp rc_pat=$rq"; breach=$((breach+1)); continue
    fi
    if [ ! -f "$o/pris.uhdm" ] || [ ! -f "$o/pat.uhdm" ]; then
      norun=$((norun+1)); continue
    fi
    "$DUMP" "$o/pris.uhdm" 2>/dev/null | sed "s#$o/##g;s#^pris.uhdm:#DB:#" > "$o/pris.dmp"
    "$DUMP" "$o/pat.uhdm"  2>/dev/null | sed "s#$o/##g;s#^pat.uhdm:#DB:#"  > "$o/pat.dmp"
    diff "$o/pris.dmp" "$o/pat.dmp" > "$o/dmp.diff" 2>&1
    [ -s "$o/dmp.diff" ] || continue
    moved=$((moved+1))
    # every CONTENT line of the diff must be a line the law claims
    bad=$(grep -E '^[<>]' "$o/dmp.diff" \
          | grep -cvE 'named_fork|fork_stmt|vpiJoinType|vpiEndLabel'); true
    if [ "$bad" -ne 0 ]; then
      echo "BREACH unclaimed=$bad $rel $view"
      grep -E '^[<>]' "$o/dmp.diff" | grep -vE 'named_fork|fork_stmt|vpiJoinType|vpiEndLabel' | head -8
      breach=$((breach+1))
    fi
    # GOLDEN SCORE on every moved cell: fork-shaped is not the same as right.
    if [ "${GOLD:-0}" = 1 ]; then
      [ -n "${CEN:-}" ] || { echo "FATAL: GOLD=1 needs CEN=<ct131cen>"; exit 3; }
      SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
      cp "$f" "$o/" 2>/dev/null
      if [ "$view" = elab ]; then SLX=-elabuhdm; else SLX=; fi
      ( cd "$o" && "$SURELOG" -parse $SLX "$(basename "$f")" -d uhdm -nobuiltin \
          -mt 0 -mp 0 -o g > sl.log 2>&1 </dev/null ); echo "rc_sl=$?" >> "$o/rcs"
      G=$o/g/slpp_all/surelog.uhdm
      if [ ! -f "$G" ]; then
        echo "BREACH no-golden-db $rel $view"; breach=$((breach+1)); continue
      fi
      "$CEN" "$G"            > "$o/g.cen"    2>/dev/null </dev/null; echo "rc_cen_g=$?"    >> "$o/rcs"
      "$CEN" "$o/pris.uhdm"  > "$o/pris.cen" 2>/dev/null </dev/null; echo "rc_cen_pris=$?" >> "$o/rcs"
      "$CEN" "$o/pat.uhdm"   > "$o/pat.cen"  2>/dev/null </dev/null; echo "rc_cen_pat=$?"  >> "$o/rcs"
      python3 "$(dirname "${BASH_SOURCE[0]}")/score131.py" \
        "$o/g.cen" "$o/pris.cen" "$o/pat.cen" > "$o/score" 2>&1
      wrong=$(grep -cE '^   (RIGHT->WRONG|WRONG->WRONG)' "$o/score"); true
      onlyo=$(grep -cE '^   ONLY-OURS' "$o/score"); true
      if [ "$wrong" -ne 0 ]; then
        echo "BREACH golden-regression $rel $view (RIGHT->WRONG/WRONG->WRONG cells: $wrong)"
        grep -E '^   (RIGHT->WRONG|WRONG->WRONG)' "$o/score" | head -6
        breach=$((breach+1))
      fi
      # ONLY-OURS on the PATCHED side is a key of ours golden does not have.
      if grep -qE '^   ONLY-OURS .* pat=[^N]' "$o/score"; then
        echo "BREACH patched-only-key $rel $view"
        grep -E '^   ONLY-OURS .* pat=[^N]' "$o/score" | head -6
        breach=$((breach+1))
      fi
    fi
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc MOVED-CELLS=$moved NO-DB=$norun BREACH=$breach"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
if [ "$CTRL" = 1 ]; then
  # POSITIVE CONTROL: the gate must FIRE when a non-fork line moves.  Feed it
  # a dump pair that differs on a line no filter accepts.
  c=$WD/_ctrl; mkdir -p "$c"
  printf 'DB:\n|vpiName:alpha\n' > "$c/pris.dmp"
  printf 'DB:\n|vpiName:beta\n'  > "$c/pat.dmp"
  diff "$c/pris.dmp" "$c/pat.dmp" > "$c/dmp.diff"
  cb=$(grep -E '^[<>]' "$c/dmp.diff" | grep -cvE 'named_fork|fork_stmt|vpiJoinType|vpiEndLabel'); true
  [ "$cb" -gt 0 ] && echo "POSITIVE-CONTROL-OK (gate saw $cb unclaimed lines)" \
                  || { echo POSITIVE-CONTROL-FAILED; exit 7; }
fi
[ "$breach" -eq 0 ] && echo BOUNDARY-PASS || { echo BOUNDARY-FAIL; exit 5; }
