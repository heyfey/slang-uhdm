#!/usr/bin/env bash
# r10v215 — THE ADVERSARIAL GRID.  MEASUREMENT ONLY; the official uhdm-cmp is
# the sole acceptance judge and never scores an arm here.
#
# Differences from the implementer's grid215.sh, both deliberate:
#  1. OUR BINARY IS RUN IN THE SAME VIEW AS GOLDEN.  grid215.sh passes
#     `-elabuhdm` to Surelog only and invokes our binary identically in both
#     columns, so its "elab" column scores golden-elab against our DEF database.
#     Here `--elabuhdm` goes to both sides (verify_golden.py's own mapping,
#     scripts/verify_golden.py:369-370).
#  2. BOTH OF OUR BINARIES are built for every arm-view and scored against the
#     SAME golden, with the whole-dump multiset scorer (dumpcen215v.py) beside
#     the modport census — so a cell where the PRISTINE binary matched golden
#     and the PATCHED one no longer does is named, whatever field it is in.
#
# Every rc is recorded (verify_golden.py reads a 139 SEGFAULT as SLANG_REJECT,
# RESUME §9).  No `grep -c` sits in a `set -e` position.  Scratch is taken from
# the command line and keyed on the arm's basename; children get </dev/null.
# The canonical Surelog is the one scripts/verify_golden.py names.
#   usage: PRIS=.. PATCHED=.. CEN=.. PY=.. gridv215.sh <armdir> <scratch> <out>
set -u
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
CEN=${CEN:?path to ct215mpcen}
DPY=${DPY:?path to dumpcen215v.py}
PY=${PY:?path to cen215.py}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
ARMS=${1:?armdir}; SCR=${2:?scratch}; OUT=${3:?out}
for t in "$PRIS" "$PATCHED" "$CEN" "$SURELOG" "$DUMP" "$CMP"; do
  [ -x "$t" ] || { echo "FATAL: not executable: $t"; exit 3; }
done
mkdir -p "$SCR" || exit 1
: > "$OUT"
n=0; nog=0; calib=0; reg=0
for f in "$ARMS"/*.sv; do
  b=$(basename "$f" .sv)
  for ev in parse elab; do
    d=$SCR/$b.$ev
    rm -rf "$d"; mkdir -p "$d" || exit 1
    cp "$f" "$d/" || exit 1
    ex=""; oex=""
    if [ "$ev" = elab ]; then ex="-elabuhdm"; oex="--elabuhdm"; fi
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex "$b.sv" > sl.log 2>&1 </dev/null ); grc=$?
    ( cd "$d" && timeout 300 "$PRIS"    "$b.sv" $oex -o o.uhdm > o.log 2>&1 </dev/null ); orc=$?
    ( cd "$d" && timeout 300 "$PATCHED" "$b.sv" $oex -o q.uhdm > q.log 2>&1 </dev/null ); qrc=$?
    g=$d/slpp_all/surelog.uhdm
    if [ ! -f "$g" ] || [ ! -f "$d/o.uhdm" ] || [ ! -f "$d/q.uhdm" ]; then
      echo "ARM $b $ev rc_surelog=$grc rc_pris=$orc rc_pat=$qrc golden=$([ -f "$g" ] && echo yes || echo NO) pris=$([ -f "$d/o.uhdm" ] && echo yes || echo NO) pat=$([ -f "$d/q.uhdm" ] && echo yes || echo NO) VERDICT=NO-DATABASE" >> "$OUT"
      nog=$((nog+1)); n=$((n+1)); continue
    fi
    bytes=SAME; cmp -s "$d/o.uhdm" "$d/q.uhdm" || bytes=MOVED
    "$CMP" "$g" "$d/o.uhdm" > "$d/cmp_pris.txt" 2>&1; pcrc=$?
    "$CMP" "$g" "$d/q.uhdm" > "$d/cmp_pat.txt"  2>&1; qcrc=$?
    ph=$(grep -c '^LHS:' "$d/cmp_pris.txt"); true
    qh=$(grep -c '^LHS:' "$d/cmp_pat.txt"); true
    echo "ARM $b $ev rc_surelog=$grc rc_pris=$orc rc_pat=$qrc bytes=$bytes cmp_pris=$(wc -l < "$d/cmp_pris.txt")/$ph cmp_pat=$(wc -l < "$d/cmp_pat.txt")/$qh rc_cmp=$pcrc/$qcrc (VERDICT NOT THE SCORER)" >> "$OUT"
    # (a) the modport census, golden-vs-golden CALIBRATED first
    "$CEN" "$g" > "$d/g.cen" 2>&1
    "$CEN" "$d/o.uhdm" > "$d/o.cen" 2>&1
    "$CEN" "$d/q.uhdm" > "$d/q.cen" 2>&1
    cal=$(python3 "$PY" "$d/g.cen" "$d/g.cen" | tail -1)
    case "$cal" in *"ONLY-GOLDEN=0 ONLY-OURS=0") : ;; *) calib=$((calib+1)) ;; esac
    echo "CALIB $b $ev $cal" >> "$OUT"
    echo "CENSUS_PRIS $b $ev $(python3 "$PY" "$d/g.cen" "$d/o.cen" | tail -1)" >> "$OUT"
    echo "CENSUS_PAT  $b $ev $(python3 "$PY" "$d/g.cen" "$d/q.cen" | tail -1)" >> "$OUT"
    python3 "$PY" "$d/g.cen" "$d/q.cen" | sed "s/^/CELL $b $ev /" >> "$OUT"
    # (b) THE WHOLE-DUMP REGRESSION SCORER
    "$DUMP" "$g" > "$d/g.dmp" 2>/dev/null
    "$DUMP" "$d/o.uhdm" > "$d/o.dmp" 2>/dev/null
    "$DUMP" "$d/q.uhdm" > "$d/q.dmp" 2>/dev/null
    python3 "$DPY" "$d/g.dmp" "$d/o.dmp" "$d/q.dmp" > "$d/dump.txt"
    tot=$(tail -1 "$d/dump.txt")
    echo "DUMP $b $ev $tot" >> "$OUT"
    case "$tot" in *"REGRESS=0 NEWJUNK=0"*) : ;; *) reg=$((reg+1)); grep -E '^(REGRESS|NEWJUNK) ' "$d/dump.txt" | sed "s/^/DUMPCELL $b $ev /" >> "$OUT" ;; esac
    n=$((n+1))
  done
done
echo "-- ARM-VIEWS SCORED: $n   NO-DATABASE: $nog   CALIB non-null: $calib   ARM-VIEWS WITH REGRESS-OR-NEWJUNK: $reg" >> "$OUT"
tail -1 "$OUT"
