#!/usr/bin/env bash
# r10uvm210 — THE GOLDEN GRID.  MEASUREMENT ONLY; the official `uhdm-cmp` is
# the sole judge and it is what scores every arm here.
#
# For every arm: build ONE REAL Surelog golden in BOTH VIEWS (`-parse -d
# coveruhdm`, and again with `-elabuhdm`), then our binary's database, then
#   (a) the OFFICIAL uhdm-cmp verdict on the whole arm design, and
#   (b) the param_assign FORM census (ct210own --key), golden vs ours, keyed
#       owner-kind x view x Lhs name x Lhs span x Rhs FORM x ref-ACTUAL kind,
#       with the golden-vs-golden CALIBRATION run FIRST in every cell.
# Every rc is recorded.  LHS is ALWAYS golden.  The canonical Surelog is the one
# `scripts/verify_golden.py` names, `~/git-repos/Surelog/build/bin/surelog`.
#
# usage: BIN=<slang-uhdm> OWN=<ct210own> [SURELOG=...] ./grid210.sh <armdir> <scratch> <out>
#
# GUARDS: a missing golden is printed as `golden=NO` and the arm-view is still
# counted (uhdm-cmp exits 0 on a missing input, RESUME §9); the slang rc is
# recorded per arm-view because `verify_golden.py` reads a 139 SEGFAULT as
# SLANG_REJECT; `grep -c` is never used in a `set -e` position.
set -u
BIN=${BIN:?path to the slang-uhdm binary under test}
OWN=${OWN:?path to ct210own}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
ARMS=${1:?armdir}; SCR=${2:?scratch}; OUT=${3:?out}
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp $CMP"; exit 3; }
mkdir -p "$SCR" || exit 1
: > "$OUT"
n=0; eq=0; ne=0; nog=0
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
      nog=$((nog+1)); continue
    fi
    "$CMP" "$g" "$d/ours.uhdm" > "$d/cmp.txt" 2>&1
    crc=$?
    lines=$(wc -l < "$d/cmp.txt")
    heads=$(grep -c '^LHS:' "$d/cmp.txt"); true
    v=CMP_NOTEQUAL; [ "$lines" -eq 0 ] && v=CMP_EQUAL
    [ "$v" = CMP_EQUAL ] && eq=$((eq+1)) || ne=$((ne+1))
    echo "ARM $b $ev rc_surelog=$grc rc_ours=$orc rc_cmp=$crc VERDICT=$v cmplines=$lines heads=$heads" >> "$OUT"
    # CALIBRATION FIRST, every cell: golden vs golden must be a null diff.
    "$OWN" --key "$g" G > "$d/g.key" 2>&1
    "$OWN" --key "$d/ours.uhdm" O > "$d/o.key" 2>&1
    cal=$(diff <(sort "$d/g.key") <(sort "$d/g.key") | wc -l)
    only_g=$(comm -23 <(sort "$d/g.key") <(sort "$d/o.key") | grep -c '^K '); true
    only_o=$(comm -13 <(sort "$d/g.key") <(sort "$d/o.key") | grep -c '^K '); true
    both=$(comm -12 <(sort "$d/g.key") <(sort "$d/o.key") | grep -c '^K '); true
    echo "KEYCEN $b $ev CALIB=$cal AGREE=$both ONLY-GOLDEN=$only_g ONLY-OURS=$only_o" >> "$OUT"
    comm -23 <(sort "$d/g.key") <(sort "$d/o.key") | sed "s/^/  ONLY-GOLDEN $b.$ev /" >> "$OUT"
    comm -13 <(sort "$d/g.key") <(sort "$d/o.key") | sed "s/^/  ONLY-OURS   $b.$ev /" >> "$OUT"
    n=$((n+1))
  done
done
{
  echo "-- ARM-VIEWS SCORED: $n   CMP_EQUAL=$eq  CMP_NOTEQUAL=$ne  NO-DATABASE=$nog"
  echo "-- NONZERO RCs: $(awk '/^ARM /{for(i=1;i<=NF;i++) if($i ~ /^rc_(surelog|ours)=/ && $i !~ /=0$/) print}' "$OUT" | wc -l)"
  echo "-- TOTAL ONLY-GOLDEN cells: $(awk -F'ONLY-GOLDEN=' '/^KEYCEN /{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
  echo "-- TOTAL ONLY-OURS   cells: $(awk -F'ONLY-OURS=' '/^KEYCEN /{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
  echo "-- TOTAL CALIB non-null: $(awk -F'CALIB=' '/^KEYCEN /{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
} >> "$OUT"
tail -5 "$OUT"
