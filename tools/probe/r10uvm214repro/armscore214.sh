#!/usr/bin/env bash
# r10uvm214 — RE-SCORE EVERY BOUNDARY MOVER AGAINST A REAL GOLDEN.
# MEASUREMENT ONLY; the official uhdm-cmp is the sole acceptance judge.
# LHS is ALWAYS golden (Surelog).
#
# The wide boundary gate (bound214.sh) reports which committed arms of EARLIER
# passes changed bytes.  RESUME §7: every such arm must be re-measured against
# golden and must move TOWARD it.  This script builds ONE REAL Surelog golden
# per moved arm in BOTH VIEWS and runs the placeholder-copy census
# (ct214bind --keycount) golden / pristine / patched through score214.py, so each
# arm gets the same four columns the corpus rows get.
#
# usage: PRIS= PATCHED= TS= CEN= SCORE= ./armscore214.sh <MOVERS file> <arm root> <scratch> <out>
#
# GUARDS: a missing golden prints golden=NO and the arm is COUNTED, never
# skipped; every rc is recorded; children get </dev/null; the scratch dir is a
# command-line argument and is never a hard-coded path.
set -u
MOV=${1:?MOVERS file}; ROOT=${2:?arm root}; SCR=${3:?scratch}; OUT=${4:?out}
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
TS=${TS:?}; CEN=${CEN:?}; SCORE=${SCORE:?}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
mkdir -p "$SCR" || exit 1
: > "$OUT"
n=0; nog=0
while read -r rel rest <&3; do
  case "$rel" in RCDIFF) continue ;; esac
  f=$ROOT/$rel
  [ -f "$f" ] || { echo "ARM $rel MISSING-SOURCE" >> "$OUT"; continue; }
  b=$(basename "$f" .sv)
  for ev in parse elab; do
    key=$(echo "$rel.$ev" | tr '/' '_')
    d=$SCR/$key; rm -rf "$d"; mkdir -p "$d" || exit 1
    cp "$f" "$d/" || exit 1
    for h in "$(dirname "$f")"/*.svh "$(dirname "$f")"/*.vh; do [ -f "$h" ] && cp "$h" "$d/"; done
    ex=""; [ "$ev" = elab ] && ex="-elabuhdm"
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex "$b.sv" > sl.log 2>&1 </dev/null ); grc=$?
    ( cd "$d" && timeout 300 "$PRIS"    "$b.sv" -o p.uhdm > p.log 2>&1 </dev/null ); prc=$?
    ( cd "$d" && timeout 300 "$PATCHED" "$b.sv" -o q.uhdm > q.log 2>&1 </dev/null ); qrc=$?
    g=$d/slpp_all/surelog.uhdm
    if [ ! -f "$g" ] || [ ! -f "$d/p.uhdm" ] || [ ! -f "$d/q.uhdm" ]; then
      echo "ARM $rel $ev rc_surelog=$grc rc_pris=$prc rc_pat=$qrc golden=$([ -f "$g" ] && echo yes || echo NO) SCORED=NO" >> "$OUT"
      nog=$((nog+1)); n=$((n+1)); continue
    fi
    "$TS" --keycount "$g"       . > "$d/g.kc"
    "$TS" --keycount "$d/p.uhdm" . > "$d/p.kc"
    "$TS" --keycount "$d/q.uhdm" . > "$d/q.kc"
    cal=$(python3 "$CEN" "$d/g.kc" "$d/g.kc" | tail -1)
    sc=$(python3 "$SCORE" "$d/g.kc" "$d/p.kc" "$d/q.kc" --all | tail -2 | tr "\n" " ")
    echo "ARM $rel $ev rc=$grc/$prc/$qrc CALIB[$cal]" >> "$OUT"
    echo "ARM $rel $ev $sc" >> "$OUT"
    python3 "$SCORE" "$d/g.kc" "$d/p.kc" "$d/q.kc" --all --names |
      grep -E '^TO-GOLDEN|^AWAY-GOLDEN|^MOVED-WRONG' |
      sed "s#^#CELL $rel $ev #" >> "$OUT"
    n=$((n+1))
  done
done 3< "$MOV"
echo "-- ARM-VIEWS SCORED: $n  NOT-SCORED: $nog" >> "$OUT"
tail -1 "$OUT"
