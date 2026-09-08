#!/usr/bin/env bash
# r10uvm215 — THE GOLDEN GRID.  MEASUREMENT ONLY; the official `uhdm-cmp` is the
# sole acceptance judge and it never scores an arm here.
#
# For every arm: build ONE REAL Surelog golden in BOTH VIEWS (`-parse -d
# coveruhdm -nobuiltin -nocache`, and again with `-elabuhdm`), then our binary's
# database, then
#   (a) the OFFICIAL uhdm-cmp verdict, RECORDED but NOT the scorer — `-nobuiltin`
#       makes golden's `design->AllPackages()` one entry shorter than ours, so
#       every arm's head is that vector-size mismatch (r10uvm210/213/214's
#       recorded caution) and the verdict cannot be read as a score;
#   (b) THE SCORER: the MODPORT census (`ct215mpcen` + `cen215.py`), keyed
#       `<defname>|<instance name>|<parent KIND>` x modport name x its io_decls,
#       with MPNULL (a null Modports POINTER — what the head's `LHS: <null>`
#       means) distinguished from MPEMPTY, golden vs ours, and the
#       golden-vs-golden CALIBRATION run FIRST in every cell.
# Every rc is recorded.  LHS is ALWAYS golden.  The canonical Surelog is the one
# `scripts/verify_golden.py` names, `~/git-repos/Surelog/build/bin/surelog`.
#
# usage: BIN=<slang-uhdm> CEN=<ct215mpcen> PY=<cen215.py> ./grid215.sh <armdir> <scratch> <out>
#
# GUARDS: a missing golden prints `golden=NO` and the arm-view is still COUNTED
# (uhdm-cmp exits 0 on a missing input, RESUME §9); the slang rc is recorded per
# arm-view because `verify_golden.py` reads a 139 SEGFAULT as SLANG_REJECT; no
# `grep -c` sits in a `set -e` position; the scratch dir is taken from the
# command line and is never a hard-coded path.
set -u
BIN=${BIN:?path to the slang-uhdm binary under test}
CEN=${CEN:?path to ct215mpcen}
PY=${PY:?path to cen215.py}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
ARMS=${1:?armdir}; SCR=${2:?scratch}; OUT=${3:?out}
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no ct215mpcen $CEN"; exit 3; }
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
    "$CEN" "$g" > "$d/g.cen" 2>&1
    "$CEN" "$d/ours.uhdm" > "$d/o.cen" 2>&1
    cal=$(python3 "$PY" "$d/g.cen" "$d/g.cen" | tail -1)
    case "$cal" in *"ONLY-GOLDEN=0 ONLY-OURS=0") : ;; *) calib=$((calib+1)) ;; esac
    echo "CALIB $b $ev $cal" >> "$OUT"
    python3 "$PY" "$d/g.cen" "$d/o.cen" > "$d/cen.txt"
    echo "CENSUS $b $ev $(tail -1 "$d/cen.txt")" >> "$OUT"
    sed "s/^/POPG $b $ev /" "$d/g.cen" >> "$OUT"
    sed "s/^/POPO $b $ev /" "$d/o.cen" >> "$OUT"
    sed -n '1,400p' "$d/cen.txt" | sed "s/^/CELL $b $ev /" >> "$OUT"
    n=$((n+1))
  done
done
echo "-- ARM-VIEWS SCORED: $n   NO-DATABASE: $nog   CALIB non-null: $calib" >> "$OUT"
tail -1 "$OUT"
