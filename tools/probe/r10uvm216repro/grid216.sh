#!/usr/bin/env bash
# r10uvm216 — THE GOLDEN GRID.  MEASUREMENT ONLY; the official `uhdm-cmp` is the
# sole acceptance judge and it NEVER scores an arm here.
#
# For every arm: build ONE REAL Surelog golden in BOTH VIEWS (`-parse -d
# coveruhdm -nobuiltin -nocache`, and again with `-elabuhdm`), then our binary's
# database, then
#   (a) the OFFICIAL uhdm-cmp verdict, RECORDED but NOT the scorer — r10uvm210's
#       caution: `-nobuiltin` makes golden's `AllPackages` shorter than ours, so
#       an arm's head is that vector-size mismatch and the verdict scores
#       nothing;
#   (b) THE SCORER: the SUBROUTINE-LISTING census (`ct216cen` + `cen216.py`),
#       keyed holder x INDEX x (kind,name,vpiAccessType,vpiDPICStr,DPIContext,
#       DPIPure,DPICIdentifier,#io,has-body) and, order-blind, holder x that
#       same payload — golden vs ours, with the golden-vs-golden CALIBRATION
#       run FIRST in every cell.
#
# Every rc is recorded (`verify_golden.py` reads a 139 SEGFAULT as SLANG_REJECT,
# RESUME §9).  A missing database prints `VERDICT=NO-DATABASE` and the arm-view
# is still COUNTED.  No `grep -c` sits in a `set -e` position.  The scratch dir
# comes from the command line and is never hard-coded.  The canonical Surelog is
# the one `scripts/verify_golden.py` names.
#
# usage: BIN=<slang-uhdm> CEN=<ct216cen> ./grid216.sh <armdir> <scratch> <out>
set -u
BIN=${BIN:?path to the slang-uhdm binary under test}
CEN=${CEN:?path to ct216cen}
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
ARMS=${1:?armdir}; SCR=${2:?scratch}; OUT=${3:?out}
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no ct216cen $CEN"; exit 3; }
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
    "$CEN" "$g" --nobuiltin > "$d/g.kc" 2>&1
    "$CEN" "$d/ours.uhdm" --nobuiltin > "$d/o.kc" 2>&1
    cal=$(python3 "$HERE/cen216.py" "$d/g.kc" "$d/g.kc" --only-diff | tail -1)
    case "$cal" in *"ONLY-GOLDEN=0 ONLY-OURS=0") : ;; *) calib=$((calib+1)) ;; esac
    echo "CALIB $b $ev $cal" >> "$OUT"
    python3 "$HERE/cen216.py" "$d/g.kc" "$d/o.kc" --only-diff > "$d/cen.txt"
    echo "CENSUS $b $ev $(tail -1 "$d/cen.txt")" >> "$OUT"
    sed -n '1,400p' "$d/cen.txt" | grep -v '^--' | sed "s|^|CELL $b $ev |" >> "$OUT"
    # the full ordered listings, both sides, so an arm can be read by eye
    python3 "$HERE/list216.py" "$d/g.kc" --dpi | sed "s|^|LISTG $b $ev |" >> "$OUT"
    python3 "$HERE/list216.py" "$d/o.kc" --dpi | sed "s|^|LISTO $b $ev |" >> "$OUT"
    n=$((n+1))
  done
done
echo "-- ARM-VIEWS SCORED: $n   NO-DATABASE: $nog   CALIB non-null: $calib" >> "$OUT"
tail -1 "$OUT"
