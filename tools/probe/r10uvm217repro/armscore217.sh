#!/usr/bin/env bash
# r10uvm217 — RE-SCORE EVERY BOUNDARY MOVER AGAINST A REAL GOLDEN.
# MEASUREMENT ONLY; the official uhdm-cmp is the sole acceptance judge.
# LHS is ALWAYS golden (Surelog).
#
# The wide boundary gate (bound217.sh) reports which committed arms of EARLIER
# passes changed bytes.  RESUME §7: every such arm must be re-measured against
# golden and must move TOWARD it.  This script builds ONE REAL Surelog golden per
# moved arm in BOTH VIEWS and runs the materialized-listing census (ct217net + cen217.py)
# golden-vs-PRISTINE and golden-vs-PATCHED, so the direction of each arm's move
# is a measurement and not an assertion.  The golden-vs-golden CALIBRATION is run
# first in every cell.
#
# usage: PRIS= PATCHED= CEN=<ct217net> PY=<cen217.py> ./armscore217.sh <MOVERS file> <arm root> <scratch> <out>
#
# GUARDS: a missing golden prints golden=NO and the arm is COUNTED, never
# skipped; every rc is recorded; children get </dev/null; the scratch dir is a
# command-line argument and is never a hard-coded path.
set -u
MOV=${1:?MOVERS file}; ROOT=${2:?arm root}; SCR=${3:?scratch}; OUT=${4:?out}
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
CEN=${CEN:?}; PY=${PY:?}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
mkdir -p "$SCR" || exit 1
: > "$OUT"
n=0; nog=0
while read -r rel rest <&3; do
  case "$rel" in RCDIFF) continue ;; esac
  f=$ROOT/$rel
  [ -f "$f" ] || { echo "ARM $rel MISSING-SOURCE" >> "$OUT"; continue; }
  b=$(basename "$f"); b=${b%.sv}; b=${b%.v}
  for ev in parse elab; do
    key=$(echo "$rel.$ev" | tr '/' '_')
    d=$SCR/$key; rm -rf "$d"; mkdir -p "$d" || exit 1
    cp "$f" "$d/" || exit 1
    for h in "$(dirname "$f")"/*.svh "$(dirname "$f")"/*.vh; do [ -f "$h" ] && cp "$h" "$d/"; done
    src=$(basename "$f")
    ex=""; [ "$ev" = elab ] && ex="-elabuhdm"
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex "$src" > sl.log 2>&1 </dev/null ); grc=$?
    ( cd "$d" && timeout 300 "$PRIS"    "$src" -o p.uhdm > p.log 2>&1 </dev/null ); prc=$?
    ( cd "$d" && timeout 300 "$PATCHED" "$src" -o q.uhdm > q.log 2>&1 </dev/null ); qrc=$?
    g=$d/slpp_all/surelog.uhdm
    if [ ! -f "$g" ] || [ ! -f "$d/p.uhdm" ] || [ ! -f "$d/q.uhdm" ]; then
      echo "ARM $rel $ev rc_surelog=$grc rc_pris=$prc rc_pat=$qrc golden=$([ -f "$g" ] && echo yes || echo NO) SCORED=NO" >> "$OUT"
      nog=$((nog+1)); n=$((n+1)); continue
    fi
    "$CEN" "$g" --vars > "$d/g.cen" 2>&1
    "$CEN" "$d/p.uhdm" --vars > "$d/p.cen" 2>&1
    "$CEN" "$d/q.uhdm" --vars > "$d/q.cen" 2>&1
    cal=$(python3 "$PY" "$d/g.cen" "$d/g.cen" | tail -1)
    sp=$(python3 "$PY" "$d/g.cen" "$d/p.cen" | tail -1)
    sq=$(python3 "$PY" "$d/g.cen" "$d/q.cen" | tail -1)
    echo "ARM $rel $ev rc=$grc/$prc/$qrc CALIB[$cal] PRISTINE[$sp] PATCHED[$sq]" >> "$OUT"
    python3 "$PY" "$d/g.cen" "$d/p.cen" | grep -E '^ONLY' | sed "s#^#CELLP $rel $ev #" >> "$OUT"
    python3 "$PY" "$d/g.cen" "$d/q.cen" | grep -E '^ONLY' | sed "s#^#CELLQ $rel $ev #" >> "$OUT"
    n=$((n+1))
  done
done 3< "$MOV"
echo "-- ARM-VIEWS SCORED: $n  NOT-SCORED: $nog" >> "$OUT"
tail -1 "$OUT"
