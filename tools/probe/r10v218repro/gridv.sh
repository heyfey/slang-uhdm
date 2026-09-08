#!/usr/bin/env bash
# r10v218 — THE VERIFIER'S GOLDEN GRID.  MEASUREMENT ONLY; the official
# uhdm-cmp is the sole acceptance judge and it never scores an arm here.
# For every arm and BOTH views, build ONE REAL Surelog golden, then BOTH
# binaries' databases, and score each against golden with the verifier's own
# census (which records the vpiActual's NAME, not only its kind).
# Every rc is recorded; a missing database prints NO-DATABASE and is COUNTED.
# usage: gridv.sh <armdir> <scratch> <out> <pristine-bin> <patched-bin> [prefix]
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CEN=${CENV:-/tmp/v218_cenv.py}
ARMS=${1:?armdir}; SCR=${2:?scratch}; OUT=${3:?out}
A=${4:?pristine}; B=${5:?patched}; PRE=${6:-work@}
for t in "$SURELOG" "$CMP" "$DUMP" "$A" "$B"; do
  [ -x "$t" ] || { echo "FATAL: no $t"; exit 3; }
done
[ -f "$CEN" ] || { echo "FATAL: no census $CEN"; exit 3; }
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
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex dut.sv > sl.log 2>&1 </dev/null ); grc=$?
    ( cd "$d" && timeout 300 "$A" dut.sv -o a.uhdm > a.log 2>&1 </dev/null ); arc=$?
    ( cd "$d" && timeout 300 "$B" dut.sv -o b.uhdm > b.log 2>&1 </dev/null ); brc=$?
    g=$d/slpp_all/surelog.uhdm
    if [ ! -f "$g" ] || [ ! -f "$d/a.uhdm" ] || [ ! -f "$d/b.uhdm" ]; then
      echo "ARM $b $ev rc_sl=$grc rc_a=$arc rc_b=$brc g=$([ -f "$g" ] && echo yes || echo NO) a=$([ -f "$d/a.uhdm" ] && echo yes || echo NO) b=$([ -f "$d/b.uhdm" ] && echo yes || echo NO) VERDICT=NO-DATABASE" >> "$OUT"
      nog=$((nog+1)); n=$((n+1)); continue
    fi
    echo "ARM $b $ev rc_sl=$grc rc_a=$arc rc_b=$brc" >> "$OUT"
    "$DUMP" "$g" > "$d/g.dump" 2>&1
    "$DUMP" "$d/a.uhdm" > "$d/a.dump" 2>&1
    "$DUMP" "$d/b.uhdm" > "$d/b.dump" 2>&1
    cal=$(python3 "$CEN" "$d/g.dump" "$d/g.dump" "$PRE" --quiet | tail -1)
    case "$cal" in *"MISSING-OURS=0 EXTRA-OURS=0 OTHER=0") : ;; *) calib=$((calib+1)) ;; esac
    echo "CALIB $b $ev $cal" >> "$OUT"
    python3 "$CEN" "$d/g.dump" "$d/a.dump" "$PRE" > "$d/cen_a.txt"
    python3 "$CEN" "$d/g.dump" "$d/b.dump" "$PRE" > "$d/cen_b.txt"
    echo "CENSUS-PRIS $b $ev $(tail -1 "$d/cen_a.txt")" >> "$OUT"
    echo "CENSUS-PAT  $b $ev $(tail -1 "$d/cen_b.txt")" >> "$OUT"
    sed -n '1,400p' "$d/cen_a.txt" | sed "s|^|CELLPRIS $b $ev |" >> "$OUT"
    sed -n '1,400p' "$d/cen_b.txt" | sed "s|^|CELLPAT  $b $ev |" >> "$OUT"
    n=$((n+1))
  done
done
echo "-- ARM-VIEWS SCORED: $n   NO-DATABASE: $nog   CALIB non-null: $calib" >> "$OUT"
tail -1 "$OUT"
