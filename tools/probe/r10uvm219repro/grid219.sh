#!/usr/bin/env bash
# r10uvm219 — THE GOLDEN GRID.  MEASUREMENT ONLY; the official `uhdm-cmp` is the
# sole acceptance judge and it never scores an arm here.
#
# For every arm: build ONE REAL Surelog golden in BOTH VIEWS (`-parse -d
# coveruhdm -nobuiltin -nocache`, and again with `-elabuhdm`), then BOTH of this
# pass's frozen binaries' databases, then
#   (a) the OFFICIAL uhdm-cmp verdict, RECORDED but NOT the scorer — `-nobuiltin`
#       makes golden's `design->AllPackages()` one entry shorter than ours, so
#       every arm's head is that vector-size mismatch (r10uvm210/213/214/215's
#       recorded caution) and the verdict cannot be read as a score;
#   (b) THE SCORER: the POSITION-KEYED materialized-listing census
#       (`ct219net` + `cen219.py`), golden vs ours, with the golden-vs-golden
#       CALIBRATION run FIRST in every arm-view.
# Every rc is recorded.  LHS is ALWAYS golden.  The canonical Surelog is the one
# `scripts/verify_golden.py` names, `~/git-repos/Surelog/build/bin/surelog`.
#
# usage: PRIS=<pristine bin> PATCHED=<patched bin> CEN=<ct219net> PY=<cen219.py> \
#          ./grid219.sh <armdir> <scratch> <out>
#
# GUARDS: a missing golden prints `golden=NO` and the arm-view is still COUNTED
# (uhdm-cmp exits 0 on a missing input, RESUME §9); each binary's rc is recorded
# per arm-view because `verify_golden.py` reads a 139 SEGFAULT as SLANG_REJECT;
# no `grep -c` sits in a `set -e` position; the scratch dir is taken from the
# command line and is never a hard-coded path.
set -u
PRIS=${PRIS:?path to the PRISTINE slang-uhdm}
PATCHED=${PATCHED:?path to the PATCHED slang-uhdm}
CEN=${CEN:?path to ct219net}
PY=${PY:?path to cen219.py}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
ARMS=${1:?armdir}; SCR=${2:?scratch}; OUT=${3:?out}
for b in "$PRIS" "$PATCHED" "$CEN" "$CMP"; do
  [ -x "$b" ] || { echo "FATAL: not executable: $b"; exit 3; }
done
mkdir -p "$SCR" || exit 1
: > "$OUT"
n=0; nog=0; calib=0
for f in "$ARMS"/*.sv; do
  b=$(basename "$f" .sv)
  for ev in parse elab; do
    d=$SCR/$b.$ev
    rm -rf "$d"; mkdir -p "$d" || exit 1
    cp "$f" "$d/" || exit 1
    ex=""; [ "$ev" = elab ] && ex="-elabuhdm"
    ( cd "$d" && timeout 600 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex "$b.sv" > sl.log 2>&1 )
    grc=$?
    ( cd "$d" && timeout 600 "$PRIS"    "$b.sv" -o pris.uhdm > pris.log 2>&1 ); prc=$?
    ( cd "$d" && timeout 600 "$PATCHED" "$b.sv" -o pat.uhdm  > pat.log  2>&1 ); qrc=$?
    g=$d/slpp_all/surelog.uhdm
    if [ ! -f "$g" ] || [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/pat.uhdm" ]; then
      echo "ARM $b $ev rc_surelog=$grc rc_pris=$prc rc_pat=$qrc golden=$([ -f "$g" ] && echo yes || echo NO) pris=$([ -f "$d/pris.uhdm" ] && echo yes || echo NO) pat=$([ -f "$d/pat.uhdm" ] && echo yes || echo NO) VERDICT=NO-DATABASE" >> "$OUT"
      nog=$((nog+1)); n=$((n+1)); continue
    fi
    "$CMP" "$g" "$d/pris.uhdm" > "$d/cmp.pris.txt" 2>&1; crp=$?
    "$CMP" "$g" "$d/pat.uhdm"  > "$d/cmp.pat.txt"  2>&1; crq=$?
    lp=$(wc -l < "$d/cmp.pris.txt"); lq=$(wc -l < "$d/cmp.pat.txt")
    hp=$(grep -c '^LHS:' "$d/cmp.pris.txt"); true
    hq=$(grep -c '^LHS:' "$d/cmp.pat.txt"); true
    echo "ARM $b $ev rc_surelog=$grc rc_pris=$prc rc_pat=$qrc rc_cmp_pris=$crp rc_cmp_pat=$crq cmplines_pris=$lp cmplines_pat=$lq heads_pris=$hp heads_pat=$hq (VERDICT NOT THE SCORER)" >> "$OUT"
    "$CEN" "$g"            --vars > "$d/g.cen" 2>&1
    "$CEN" "$d/pris.uhdm"  --vars > "$d/p.cen" 2>&1
    "$CEN" "$d/pat.uhdm"   --vars > "$d/q.cen" 2>&1
    cal=$(python3 "$PY" "$d/g.cen" "$d/g.cen" | tail -1)
    case "$cal" in *"POSDIFF=0 ONLY-GOLDEN=0 ONLY-OURS=0 BAG-ONLY-GOLDEN=0 BAG-ONLY-OURS=0 MISORDERED-CELLS=0") : ;; *) calib=$((calib+1)) ;; esac
    echo "CALIB $b $ev $cal" >> "$OUT"
    python3 "$PY" "$d/g.cen" "$d/p.cen" > "$d/cen.pris.txt"
    python3 "$PY" "$d/g.cen" "$d/q.cen" > "$d/cen.pat.txt"
    echo "CENSUS-PRIS $b $ev $(tail -1 "$d/cen.pris.txt")" >> "$OUT"
    echo "CENSUS-PAT  $b $ev $(tail -1 "$d/cen.pat.txt")" >> "$OUT"
    grep '^ARITY' "$d/g.cen" | sed "s/^/ARITYG $b $ev /" >> "$OUT"
    grep '^ARITY' "$d/p.cen" | sed "s/^/ARITYP $b $ev /" >> "$OUT"
    grep '^ARITY' "$d/q.cen" | sed "s/^/ARITYQ $b $ev /" >> "$OUT"
    sed -n '1,300p' "$d/cen.pris.txt" | sed "s/^/CELLP $b $ev /" >> "$OUT"
    sed -n '1,300p' "$d/cen.pat.txt"  | sed "s/^/CELLQ $b $ev /" >> "$OUT"
    n=$((n+1))
  done
done
echo "-- ARM-VIEWS SCORED: $n   NO-DATABASE: $nog   CALIB non-null: $calib" >> "$OUT"
tail -1 "$OUT"
