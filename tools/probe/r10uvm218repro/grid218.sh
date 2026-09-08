#!/usr/bin/env bash
# r10uvm218 — THE GOLDEN GRID.  MEASUREMENT ONLY; the official `uhdm-cmp`
# (`~/git-repos/UHDM/build/bin/uhdm-cmp`) is the sole acceptance judge and it
# NEVER scores an arm here.
#
# For every arm: build ONE REAL Surelog golden in BOTH VIEWS (`-parse -d
# coveruhdm -nobuiltin -nocache`, and again with `-elabuhdm`), then our
# binary's database, then
#   (a) the OFFICIAL uhdm-cmp verdict, RECORDED but NOT the scorer (r10uvm210's
#       caution: `-nobuiltin` makes golden's AllPackages shorter than ours, so
#       every arm's head is that vector-size mismatch);
#   (b) THE SCORER: `cen218.py`, the reference-actual census, golden vs ours,
#       with the golden-vs-golden CALIBRATION run FIRST in every cell.
#
# Every rc is recorded (`verify_golden.py` reads a 139 SEGFAULT as SLANG_REJECT,
# RESUME §9).  A missing database prints VERDICT=NO-DATABASE and the arm-view is
# still COUNTED — a driver that reaches nothing must never read as perfection.
# Surelog and our binary run in the SAME directory (a UHDM database records the
# source file's ABSOLUTE path — buvm8's `bndarms` trap).  The scratch directory
# comes from the command line and is never hard-coded, and no `grep -c` sits in
# a `set -e` position.  The canonical Surelog is the one
# `scripts/verify_golden.py` names (earl120's R4 trap).
#
# usage: BIN=<slang-uhdm> ./grid218.sh <armdir> <scratch> <out> [prefix]
set -u
BIN=${BIN:?path to the slang-uhdm binary under test}
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
ARMS=${1:?armdir}; SCR=${2:?scratch}; OUT=${3:?out}; PRE=${4:-work@}
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
[ -x "$SURELOG" ] || { echo "FATAL: no surelog $SURELOG"; exit 3; }
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp $CMP"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump $DUMP"; exit 3; }
mkdir -p "$SCR" || exit 1
: > "$OUT"
n=0; nog=0; calib=0
for f in "$ARMS"/*/dut.sv; do
  b=$(basename "$(dirname "$f")")
  for ev in parse elab; do
    d=$SCR/$b.$ev
    rm -rf "$d"; mkdir -p "$d" || exit 1
    cp "$f" "$d/" || exit 1
    ex=""; [ "$ev" = elab ] && ex="-elabuhdm"
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex dut.sv > sl.log 2>&1 )
    grc=$?
    ( cd "$d" && timeout 300 "$BIN" dut.sv -o ours.uhdm > ours.log 2>&1 ); orc=$?
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
    "$DUMP" "$g" > "$d/g.dump" 2>&1
    "$DUMP" "$d/ours.uhdm" > "$d/o.dump" 2>&1
    cal=$(python3 "$HERE/cen218.py" "$d/g.dump" "$d/g.dump" "$PRE" --quiet | tail -1)
    case "$cal" in *"MISSING-OURS=0 EXTRA-OURS=0 OTHER=0") : ;; *) calib=$((calib+1)) ;; esac
    echo "CALIB $b $ev $cal" >> "$OUT"
    python3 "$HERE/cen218.py" "$d/g.dump" "$d/o.dump" "$PRE" > "$d/cen.txt"
    echo "CENSUS $b $ev $(tail -1 "$d/cen.txt")" >> "$OUT"
    sed -n '1,400p' "$d/cen.txt" | sed "s|^|CELL $b $ev |" >> "$OUT"
    n=$((n+1))
  done
done
echo "-- ARM-VIEWS SCORED: $n   NO-DATABASE: $nog   CALIB non-null: $calib" >> "$OUT"
tail -1 "$OUT"
