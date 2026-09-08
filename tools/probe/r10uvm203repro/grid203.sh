#!/usr/bin/env bash
# r10uvm203 — THE GRID.  MEASUREMENT ONLY; the official uhdm-cmp is the sole
# judge; this scores a CENSUS and nothing else.  LHS is ALWAYS golden.
#
# For every arm, in BOTH views (`-parse` and `-parse -elabuhdm`): build ONE
# REAL Surelog golden with the canonical binary the harness itself names, then
# both of this pass's frozen binaries, then join the net/variable listing
# census golden x ours.  CALIBRATE golden-vs-golden FIRST (RESUME §9) — it must
# read AGREE=<all> and everything else 0.  Every rc is recorded, including the
# ones that are nonzero.
#
# usage: PRIS=<bin> PATCHED=<bin> CEN=<ct203cen> JOIN=<cen203.py> \
#        SURELOG=<surelog> ./grid203.sh <armdir> <scratch> <out>
set -u
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}; CEN=${CEN:?}; JOIN=${JOIN:?}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
ARMS=${1:?armdir}; SCR=${2:?scratch}; OUT=${3:?out}
mkdir -p "$SCR" || exit 1
: > "$OUT"
n=0
for f in "$ARMS"/*.sv; do
  b=$(basename "$f" .sv)
  for ev in parse elab; do
    d=$SCR/$b.$ev
    rm -rf "$d"; mkdir -p "$d" || exit 1
    cp "$f" "$d/" || exit 1
    ex=""; [ "$ev" = elab ] && ex="-elabuhdm"
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex "$b.sv" > sl.log 2>&1 </dev/null )
    grc=$?
    ( cd "$d" && timeout 300 "$PRIS"    "$b.sv" -o pris.uhdm    > pris.log 2>&1 </dev/null ); prc=$?
    ( cd "$d" && timeout 300 "$PATCHED" "$b.sv" -o patched.uhdm > patched.log 2>&1 </dev/null ); qrc=$?
    g=$d/slpp_all/surelog.uhdm
    echo "ARM $b $ev rc_surelog=$grc rc_pristine=$prc rc_patched=$qrc golden=$([ -f "$g" ] && echo yes || echo NO)" >> "$OUT"
    [ -f "$g" ] || continue
    "$CEN" "$g" > "$d/g.cells" 2>/dev/null
    echo "CENSUM CALIB:$b.$ev $(python3 "$JOIN" "$d/g.cells" "$d/g.cells")" >> "$OUT"
    if [ -f "$d/pris.uhdm" ]; then
      "$CEN" "$d/pris.uhdm" > "$d/p.cells" 2>/dev/null
      echo "CENSUM PRIS:$b.$ev $(python3 "$JOIN" "$d/g.cells" "$d/p.cells")" >> "$OUT"
      python3 "$JOIN" "$d/g.cells" "$d/p.cells" --diffs | sed "s/^/CELL PRIS:$b.$ev /" >> "$OUT"
    fi
    if [ -f "$d/patched.uhdm" ]; then
      "$CEN" "$d/patched.uhdm" > "$d/q.cells" 2>/dev/null
      echo "CENSUM PATCHED:$b.$ev $(python3 "$JOIN" "$d/g.cells" "$d/q.cells")" >> "$OUT"
      python3 "$JOIN" "$d/g.cells" "$d/q.cells" --diffs | sed "s/^/CELL PATCHED:$b.$ev /" >> "$OUT"
    fi
    n=$((n+1))
  done
done
echo "-- ARM-VIEWS BUILT: $n" >> "$OUT"
sum () {
  echo "-- $1  $(grep -c "^CENSUM $1:" "$OUT") arm-views, AGREE $(awk -F'AGREE=' '/^CENSUM '"$1"':/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT"), TS-DIFF $(awk -F'TS-DIFF=' '/^CENSUM '"$1"':/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT"), ONLY-GOLDEN $(awk -F'ONLY-GOLDEN=' '/^CENSUM '"$1"':/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT"), ONLY-OURS $(awk -F'ONLY-OURS=' '/^CENSUM '"$1"':/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
}
{ sum CALIB; sum PRIS; sum PATCHED
  echo "-- NONZERO RCs: $(awk '/^ARM /{for(i=1;i<=NF;i++) if($i ~ /^rc_/ && $i !~ /=0$/) print}' "$OUT" | wc -l)"
} >> "$OUT"
tail -4 "$OUT"
