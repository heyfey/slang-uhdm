#!/usr/bin/env bash
# r10uvm214 — THE GOLDEN GRID.  MEASUREMENT ONLY; the official `uhdm-cmp` is the
# sole acceptance judge and it never scores an arm here.
#
# For every arm: build ONE REAL Surelog golden in BOTH VIEWS (`-parse -d
# coveruhdm -nobuiltin -nocache`, and again with `-elabuhdm`), then our binary's
# database, then
#   (a) the OFFICIAL uhdm-cmp verdict, RECORDED but NOT the scorer —
#       r10uvm210/213's recorded caution: `-nobuiltin` makes golden's
#       `design->AllPackages()` one entry shorter than ours, so every arm's head
#       is that vector-size mismatch and the verdict is unusable as a score;
#   (b) THE SCORER: the package-parameter BINDING census (`ct214bind
#       --keycount`), keyed `ref|<name>|<line:col>` x `ACT=<what it is bound
#       to, with the bound object's own LISTING>` x `<holder chain>`, golden vs
#       ours, with the golden-vs-golden CALIBRATION run FIRST in every cell.
# Every rc is recorded.  LHS is ALWAYS golden.  The canonical Surelog is the one
# `scripts/verify_golden.py` names, `~/git-repos/Surelog/build/bin/surelog`.
#
# usage: BIN=<slang-uhdm> TS=<ct214bind> CEN=<cen214.py> ./grid214.sh <armdir> <scratch> <out>
#
# GUARDS: a missing golden prints `golden=NO` and the arm-view is still COUNTED
# (uhdm-cmp exits 0 on a missing input, RESUME §9); the slang rc is recorded per
# arm-view because `verify_golden.py` reads a 139 SEGFAULT as SLANG_REJECT; no
# `grep -c` sits in a `set -e` position; the scratch dir is taken from the
# command line and is never a hard-coded path.
set -u
BIN=${BIN:?path to the slang-uhdm binary under test}
TS=${TS:?path to ct214bind}
CEN=${CEN:?path to cen214.py}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
ARMS=${1:?armdir}; SCR=${2:?scratch}; OUT=${3:?out}
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
[ -x "$TS" ]  || { echo "FATAL: no ct214bind $TS"; exit 3; }
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp $CMP"; exit 3; }
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
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex "$b.sv" > sl.log 2>&1 )
    grc=$?
    ( cd "$d" && timeout 300 "$BIN" "$b.sv" -o ours.uhdm > ours.log 2>&1 ); orc=$?
    g=$d/slpp_all/surelog.uhdm
    if [ ! -f "$g" ] || [ ! -f "$d/ours.uhdm" ]; then
      echo "ARM $b $ev rc_surelog=$grc rc_ours=$orc golden=$([ -f "$g" ] && echo yes || echo NO) ours=$([ -f "$d/ours.uhdm" ] && echo yes || echo NO) VERDICT=NO-DATABASE" >> "$OUT"
      nog=$((nog+1)); n=$((n+1)); continue
    fi
    "$CMP" "$g" "$d/ours.uhdm" > "$d/cmp.txt" 2>&1
    crc=$?
    lines=$(wc -l < "$d/cmp.txt")
    heads=$(grep -c '^LHS:' "$d/cmp.txt"); true
    echo "ARM $b $ev rc_surelog=$grc rc_ours=$orc rc_cmp=$crc cmplines=$lines heads=$heads (VERDICT NOT THE SCORER)" >> "$OUT"
    "$TS" --keycount "$g" . > "$d/g.kc" 2>&1
    "$TS" --keycount "$d/ours.uhdm" . > "$d/o.kc" 2>&1
    cal=$(python3 "$CEN" "$d/g.kc" "$d/g.kc" | tail -1)
    case "$cal" in *"ONLY-GOLDEN=0 ONLY-OURS=0") : ;; *) calib=$((calib+1)) ;; esac
    echo "CALIB $b $ev $cal" >> "$OUT"
    python3 "$CEN" "$d/g.kc" "$d/o.kc" > "$d/cen.txt"
    echo "CENSUS $b $ev $(tail -1 "$d/cen.txt")" >> "$OUT"
    "$TS" --pop "$g" . | sed "s/^/POPG $b $ev /" >> "$OUT"
    "$TS" --pop "$d/ours.uhdm" . | sed "s/^/POPO $b $ev /" >> "$OUT"
    sed -n '1,400p' "$d/cen.txt" | sed "s/^/CELL $b $ev /" >> "$OUT"
    n=$((n+1))
  done
done
echo "-- ARM-VIEWS SCORED: $n   NO-DATABASE: $nog   CALIB non-null: $calib" >> "$OUT"
tail -1 "$OUT"
