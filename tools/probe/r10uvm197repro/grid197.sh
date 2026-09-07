#!/usr/bin/env bash
# r10uvm197 — THE GRID.  MEASUREMENT ONLY; uhdm-cmp is the sole judge.
#
# For every arm: build ONE REAL Surelog golden (`-parse -d coveruhdm`, and
# again with `-elabuhdm`), then both binaries' databases, then score the
# materialized-parameter SIZE census golden x ours on each.  Every rc is
# recorded.  LHS is ALWAYS golden.
#
# usage: PRIS=<pristine bin> PATCHED=<patched bin> CEN=<ct197cen> \
#        SURELOG=<surelog> ./grid197.sh <armdir> <scratch> <out>
set -u
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}; CEN=${CEN:?}
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
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex "$b.sv" > sl.log 2>&1 )
    grc=$?
    ( cd "$d" && timeout 300 "$PRIS"    "$b.sv" -o pris.uhdm    > pris.log 2>&1 ); prc=$?
    ( cd "$d" && timeout 300 "$PATCHED" "$b.sv" -o patched.uhdm > patched.log 2>&1 ); qrc=$?
    g=$d/slpp_all/surelog.uhdm
    echo "ARM $b $ev rc_surelog=$grc rc_pristine=$prc rc_patched=$qrc golden=$([ -f "$g" ] && echo yes || echo NO)" >> "$OUT"
    [ -f "$g" ] || continue
    [ -f "$d/pris.uhdm" ]    && "$CEN" --cen "$g" "$d/pris.uhdm"    "PRIS:$b.$ev"    >> "$OUT" 2>&1
    [ -f "$d/patched.uhdm" ] && "$CEN" --cen "$g" "$d/patched.uhdm" "PATCHED:$b.$ev" >> "$OUT" 2>&1
    n=$((n+1))
  done
done
echo "-- CELLS BUILT: $n" >> "$OUT"
awk '/^CENSUM PRIS:/   {p_ag+=$4; }' "$OUT" >/dev/null 2>&1
{
echo "-- PRISTINE  $(grep -c '^CENSUM PRIS:' "$OUT") cells, SIZE-DIFF total $(awk -F'SIZE-DIFF=' '/^CENSUM PRIS:/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT"), ONLY-GOLDEN $(awk -F'ONLY-GOLDEN=' '/^CENSUM PRIS:/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT"), ONLY-OURS $(awk -F'ONLY-OURS=' '/^CENSUM PRIS:/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT"), AGREE $(awk -F'AGREE=' '/^CENSUM PRIS:/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
echo "-- PATCHED   $(grep -c '^CENSUM PATCHED:' "$OUT") cells, SIZE-DIFF total $(awk -F'SIZE-DIFF=' '/^CENSUM PATCHED:/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT"), ONLY-GOLDEN $(awk -F'ONLY-GOLDEN=' '/^CENSUM PATCHED:/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT"), ONLY-OURS $(awk -F'ONLY-OURS=' '/^CENSUM PATCHED:/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT"), AGREE $(awk -F'AGREE=' '/^CENSUM PATCHED:/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
echo "-- NONZERO RCs: $(awk '/^ARM /{for(i=1;i<=NF;i++) if($i ~ /^rc_/ && $i !~ /=0$/) print}' "$OUT" | wc -l)"
} >> "$OUT"
tail -3 "$OUT"
