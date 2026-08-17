#!/usr/bin/env bash
# r10rgg5/boundary.sh -- re-run every COMMITTED grid this law could plausibly
# reach, from a PRIVATE COPY (never the repo tree), and report base-vs-pat.
#
#   usage: BASE=<bin> PAT=<bin> ./boundary.sh <scratchroot> [arm...]
#
# ARMS
#   rgg2lit   r10rgg2's a1/b1/c1/d1 write-back cells + real/ + vsweep --
#             the LITERAL value at each cell's own position (rgg2's claim).
#   vrgg2     r10vrgg2's 40+ demand-gate cells -- the 13 pristine-right cells
#             that the DEMAND GATE exists to protect.
#   rgg2byte  the a1/b1/c1/d1 cells' WHOLE DUMPS, byte compared base vs pat:
#             the law must not reach a single one of them.
#
# GUARDS
#   * every arm runs from a COPY under <scratchroot>; the repo tree is read-only.
#   * an arm whose driver produces no rows prints NO-ROWS and is counted.
#   * rgg2byte has a POSITIVE CONTROL (CTRL=1): each patched dump is compared
#     with the WRONG cell's base dump, and every pair must be flagged -- so a
#     "0 movers" reading is not the comparator failing to look.
set -u
ROOT=${1:?scratch root}; shift || true
ARMS=${*:-rgg2lit vrgg2 rgg2byte}
BASE=${BASE:?BASE=<binary>}; PAT=${PAT:?PAT=<binary>}
SRC=$(cd "$(dirname "$0")/.." && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
mkdir -p "$ROOT" || exit 1
bad=0
for arm in $ARMS; do
  echo "======== ARM $arm"
  case $arm in
    rgg2lit)
      rm -rf "$ROOT/rgg2"; cp -r "$SRC/r10rgg2repro" "$ROOT/rgg2"
      n=0
      for f in a1_rgg2 b1_rgg2 c1_rgg2 d1_rgg2; do
        w="$ROOT/rgg2/$f.d"; mkdir -p "$w"; cp "$ROOT/rgg2/$f.sv" "$w/dut.sv"
        ( cd "$w" && "$SL" -parse -nopython -d uhdm -mt 0 dut.sv > gold.dump 2> gold.err )
        for tag in BASE PAT; do
          b=$([ $tag = BASE ] && echo "$BASE" || echo "$PAT")
          ( cd "$w" && "$b" --single-unit dut.sv -o $tag.uhdm > $tag.log 2>&1 )
          "$DUMP" "$w/$tag.uhdm" > "$w/$tag.dump" 2>&1
        done
        # NOT a join: cells.py prints SEVERAL rows per position (one per read
        # site), so a key join cross-products them and manufactures phantom
        # BASE!=PAT rows -- the first version of this arm printed 100+ of them
        # on grids whose whole dumps are byte-identical.  The correct comparator
        # is a straight DIFF of the two side's row LISTS.
        echo "-- $f  cells: base-vs-pat row-list diff"
        python3 "$ROOT/rgg2/cells.py" "$w/BASE.dump" 2>/dev/null | sort > "$w/$f.base.rows"
        python3 "$ROOT/rgg2/cells.py" "$w/PAT.dump"  2>/dev/null | sort > "$w/$f.pat.rows"
        rb=$(wc -l < "$w/$f.base.rows"); rp=$(wc -l < "$w/$f.pat.rows")
        if [ "$rb" -eq 0 ] || [ "$rp" -eq 0 ]; then
          echo "  NO-ROWS ($f base=$rb pat=$rp)"; bad=$((bad+1))
        elif diff -q "$w/$f.base.rows" "$w/$f.pat.rows" > /dev/null; then
          echo "  IDENTICAL ($rb read positions)"
        else
          echo "  MOVED:"; diff "$w/$f.base.rows" "$w/$f.pat.rows" | sed 's/^/    /'
          bad=$((bad+1))
        fi
        n=$((n+1))
      done
      [ "$n" -eq 4 ] || { echo "NO-ROWS"; bad=$((bad+1)); }
      echo "-- real/ (the literal 30:22 per cell)"
      BASE=$BASE PAT=$PAT "$ROOT/rgg2/real/run_real.sh" "$ROOT/rgg2real" || bad=$((bad+1))
      echo "-- vsweep"
      BASE=$BASE PAT=$PAT "$ROOT/rgg2/vsweep_run.sh" "$ROOT/rgg2vs" || bad=$((bad+1))
      ;;
    vrgg2)
      rm -rf "$ROOT/vrgg2"; cp -r "$SRC/r10vrgg2repro" "$ROOT/vrgg2"
      cp -r "$SRC/r10rgg2repro" "$ROOT/r10rgg2repro"   # run_arm.sh reads ../r10rgg2repro/cells.py
      out=$(BASE=$BASE PAT=$PAT "$ROOT/vrgg2/run_arm.sh" "$ROOT"/vrgg2/[wxyz]*/ 2>&1)
      echo "$out"
      echo "$out" | grep -q '^CELL' || { echo NO-ROWS; bad=$((bad+1)); }
      ;;
    rgg2byte)
      w="$ROOT/rgg2"
      [ -d "$w" ] || { echo "NO-ROWS (run rgg2lit first)"; bad=$((bad+1)); continue; }
      mv=0; n=0
      for f in a1_rgg2 b1_rgg2 c1_rgg2 d1_rgg2; do
        d="$w/$f.d"
        [ -f "$d/BASE.dump" ] && [ -f "$d/PAT.dump" ] || { echo "NO-DUMP $f"; bad=$((bad+1)); continue; }
        n=$((n+1))
        if cmp -s <(tail -n +2 "$d/BASE.dump") <(tail -n +2 "$d/PAT.dump"); then
          echo "  IDENTICAL $f"
        else
          echo "  MOVER     $f"; mv=$((mv+1))
        fi
      done
      echo "  byte movers=$mv / $n"
      if [ "${CTRL:-0}" = 1 ]; then
        flag=0
        for f in a1_rgg2 b1_rgg2 c1_rgg2 d1_rgg2; do
          for g in a1_rgg2 b1_rgg2 c1_rgg2 d1_rgg2; do
            [ "$f" = "$g" ] && continue
            cmp -s <(tail -n +2 "$w/$f.d/PAT.dump") <(tail -n +2 "$w/$g.d/BASE.dump") || flag=$((flag+1))
          done
        done
        echo "  POSITIVE CONTROL (patched vs the WRONG cell's base): $flag / 12 flagged"
        [ "$flag" -eq 12 ] || { echo CONTROL_FAILED; bad=$((bad+1)); }
      fi
      ;;
    *) echo "unknown arm $arm"; bad=$((bad+1)) ;;
  esac
done
echo "PROBLEMS=$bad"
