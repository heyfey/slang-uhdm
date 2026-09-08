#!/usr/bin/env bash
# r10uvm216 — THE BOUNDARY ARM RE-SCORER.  MEASUREMENT ONLY.
#
# `bound216.sh` says WHICH committed arms moved; it cannot say whether they
# moved toward golden.  This script takes the mover list, builds a REAL Surelog
# golden for each moved arm in BOTH views (`-parse -d coveruhdm -nobuiltin
# -nocache`, and again with `-elabuhdm`) with the canonical Surelog
# `scripts/verify_golden.py` names, and re-scores each arm with the
# subroutine-listing census on BOTH binaries — the ABSOLUTE-index family
# (`cen216.py`) and the SHIFT-IMMUNE order family (`rank216.py`), which is the
# one that survives an entry only one side holds.
#
# TO-GOLDEN  = a cell that differed on pristine and agrees on patched
# AWAY       = a cell that agreed on pristine and differs on patched
# STILL-WRONG= differs on both
#
# Every rc is recorded.  A missing golden is reported, not skipped silently.
#   usage: PRIS=.. PATCHED=.. ./armscore216.sh <movers-file> <arms-root> <scratch> <out>
set -u
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
HERE=$(cd "$(dirname "$0")" && pwd)
CEN=${CEN:?path to ct216cen}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
MOV=${1:?movers file}; ROOT=${2:?arms root}; SCR=${3:?scratch}; OUT=${4:?out}
mkdir -p "$SCR" || exit 1
: > "$OUT"
n=0; nog=0; tg=0; aw=0; sw=0
while IFS=$'\t' read -r rel rest; do
  case "$rel" in RCDIFF*) echo "RCDIFF-ROW $rel $rest" >> "$OUT"; continue ;; esac
  f=$ROOT/$rel
  [ -f "$f" ] || { echo "ARM $rel MISSING-SOURCE" >> "$OUT"; continue ; }
  for ev in parse elab; do
    key=$(echo "$rel" | tr '/' '_').$ev
    d=$SCR/$key; rm -rf "$d"; mkdir -p "$d" || exit 1
    cp "$f" "$d/" 2>/dev/null
    for h in "$(dirname "$f")"/*.svh "$(dirname "$f")"/*.vh; do [ -f "$h" ] && cp "$h" "$d/"; done
    b=$(basename "$f")
    ex=""; [ "$ev" = elab ] && ex="-elabuhdm"
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex "$b" > sl.log 2>&1 </dev/null ); grc=$?
    ( cd "$d" && timeout 300 "$PRIS"    "$b" $ex -o o.uhdm > o.log 2>&1 </dev/null ); orc=$?
    ( cd "$d" && timeout 300 "$PATCHED" "$b" $ex -o q.uhdm > q.log 2>&1 </dev/null ); qrc=$?
    g=$d/slpp_all/surelog.uhdm
    n=$((n+1))
    if [ ! -f "$g" ] || [ ! -f "$d/o.uhdm" ] || [ ! -f "$d/q.uhdm" ]; then
      echo "ARM $rel $ev rc_surelog=$grc rc_pris=$orc rc_pat=$qrc NO-DATABASE" >> "$OUT"; nog=$((nog+1)); continue
    fi
    "$CEN" "$g" --nobuiltin > "$d/g.kc"; "$CEN" "$d/o.uhdm" --nobuiltin > "$d/o.kc"; "$CEN" "$d/q.uhdm" --nobuiltin > "$d/q.kc"
    cal=$(python3 "$HERE/cen216.py" "$d/g.kc" "$d/g.kc" --only-diff | tail -1)
    po=$(python3 "$HERE/cen216.py" "$d/g.kc" "$d/o.kc" --only-diff | tail -1)
    pq=$(python3 "$HERE/cen216.py" "$d/g.kc" "$d/q.kc" --only-diff | tail -1)
    ro=$(python3 "$HERE/rank216.py" "$d/g.kc" "$d/o.kc" --only-diff | tail -1)
    rq=$(python3 "$HERE/rank216.py" "$d/g.kc" "$d/q.kc" --only-diff | tail -1)
    echo "ARM $rel $ev rc_surelog=$grc rc_pris=$orc rc_pat=$qrc CALIB[$cal]" >> "$OUT"
    echo "   POS  pris[$po] pat[$pq]" >> "$OUT"
    echo "   RANK pris[$ro] pat[$rq]" >> "$OUT"
    # cell-level verdicts on the SHIFT-IMMUNE family
    python3 "$HERE/rank216.py" "$d/g.kc" "$d/o.kc" --only-diff | grep -v '^--' | cut -f3 | sort > "$d/wrong.pris"
    python3 "$HERE/rank216.py" "$d/g.kc" "$d/q.kc" --only-diff | grep -v '^--' | cut -f3 | sort > "$d/wrong.pat"
    a=$(comm -23 "$d/wrong.pris" "$d/wrong.pat" | grep -c .); true
    b2=$(comm -13 "$d/wrong.pris" "$d/wrong.pat" | grep -c .); true
    c=$(comm -12 "$d/wrong.pris" "$d/wrong.pat" | grep -c .); true
    tg=$((tg+a)); aw=$((aw+b2)); sw=$((sw+c))
    echo "   VERDICT TO-GOLDEN=$a AWAY=$b2 STILL-WRONG=$c" >> "$OUT"
    comm -13 "$d/wrong.pris" "$d/wrong.pat" | sed "s|^|   AWAYCELL $rel $ev |" >> "$OUT"
  done
done < "$MOV"
echo "-- ARM-VIEWS=$n NO-DATABASE=$nog TO-GOLDEN=$tg AWAY-GOLDEN=$aw STILL-WRONG=$sw" >> "$OUT"
tail -1 "$OUT"
