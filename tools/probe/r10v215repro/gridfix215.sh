#!/usr/bin/env bash
# r10v215 — THE THREE-BINARY GRID.  MEASUREMENT ONLY; the official uhdm-cmp is
# the sole acceptance judge.  Same construction as gridv215.sh (our binary runs
# in the SAME view as golden, `--elabuhdm` on both sides) but it builds THREE of
# our databases per arm-view — PRISTINE, the implementer's PATCHED, and the
# VERIFIER-FIXED one — against ONE golden, so the fix can be shown to be
# pristine-right-preserving where the patch was not.
# Every rc is recorded; children get </dev/null; scratch comes from the command
# line.  The canonical Surelog is the one scripts/verify_golden.py names.
#   usage: PRIS=.. PATCHED=.. FIXED=.. CEN=.. DPY=.. PY=.. gridfix215.sh <armdir> <scratch> <out>
set -u
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}; FIXED=${FIXED:?}
CEN=${CEN:?}; DPY=${DPY:?}; PY=${PY:?}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
ARMS=${1:?armdir}; SCR=${2:?scratch}; OUT=${3:?out}
for t in "$PRIS" "$PATCHED" "$FIXED" "$CEN" "$SURELOG" "$DUMP"; do
  [ -x "$t" ] || { echo "FATAL: not executable: $t"; exit 3; }
done
mkdir -p "$SCR" || exit 1
: > "$OUT"
n=0; nog=0; calib=0; awaypat=0; awayfix=0
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
    ( cd "$d" && timeout 300 "$FIXED"   "$b.sv" $oex -o r.uhdm > r.log 2>&1 </dev/null ); rrc=$?
    g=$d/slpp_all/surelog.uhdm
    slerr=$(grep -a '^\[  ERROR\] :' "$d/sl.log" | tail -1)
    if [ ! -f "$g" ] || [ ! -f "$d/o.uhdm" ] || [ ! -f "$d/q.uhdm" ] || [ ! -f "$d/r.uhdm" ]; then
      echo "ARM $b $ev rc_surelog=$grc rc_pris=$orc rc_pat=$qrc rc_fix=$rrc VERDICT=NO-DATABASE" >> "$OUT"
      nog=$((nog+1)); n=$((n+1)); continue
    fi
    echo "ARM $b $ev rc_surelog=$grc ($slerr) rc_pris=$orc rc_pat=$qrc rc_fix=$rrc pat_vs_fix_bytes=$(cmp -s "$d/q.uhdm" "$d/r.uhdm" && echo SAME || echo MOVED)" >> "$OUT"
    for x in g o q r; do
      case $x in g) src=$g ;; *) src=$d/$x.uhdm ;; esac
      "$CEN" "$src" > "$d/$x.cen" 2>&1
      "$DUMP" "$src" > "$d/$x.dmp" 2>/dev/null
    done
    cal=$(python3 "$PY" "$d/g.cen" "$d/g.cen" | tail -1)
    case "$cal" in *"ONLY-GOLDEN=0 ONLY-OURS=0") : ;; *) calib=$((calib+1)) ;; esac
    echo "CALIB $b $ev $cal" >> "$OUT"
    echo "CEN_PRIS $b $ev $(python3 "$PY" "$d/g.cen" "$d/o.cen" | tail -1)" >> "$OUT"
    echo "CEN_PAT  $b $ev $(python3 "$PY" "$d/g.cen" "$d/q.cen" | tail -1)" >> "$OUT"
    echo "CEN_FIX  $b $ev $(python3 "$PY" "$d/g.cen" "$d/r.cen" | tail -1)" >> "$OUT"
    python3 "$DPY" "$d/g.dmp" "$d/o.dmp" "$d/q.dmp" > "$d/dump_pat.txt"
    python3 "$DPY" "$d/g.dmp" "$d/o.dmp" "$d/r.dmp" > "$d/dump_fix.txt"
    tp=$(tail -1 "$d/dump_pat.txt"); tf=$(tail -1 "$d/dump_fix.txt")
    echo "DUMP_PAT $b $ev $tp" >> "$OUT"
    echo "DUMP_FIX $b $ev $tf" >> "$OUT"
    case "$tp" in *"AWAY=0 "*) : ;; *) awaypat=$((awaypat+1)); grep -a '^AWAY' "$d/dump_pat.txt" | sed "s/^/AWAYCELL_PAT $b $ev /" >> "$OUT" ;; esac
    case "$tf" in *"AWAY=0 "*) : ;; *) awayfix=$((awayfix+1)); grep -a '^AWAY' "$d/dump_fix.txt" | sed "s/^/AWAYCELL_FIX $b $ev /" >> "$OUT" ;; esac
    n=$((n+1))
  done
done
echo "-- ARM-VIEWS SCORED: $n   NO-DATABASE: $nog   CALIB non-null: $calib   ARM-VIEWS WITH AWAY>0: patched=$awaypat fixed=$awayfix" >> "$OUT"
tail -1 "$OUT"
