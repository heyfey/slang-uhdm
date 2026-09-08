#!/usr/bin/env bash
# r10v210 (VERIFIER of r10uvm210) — the ADVERSARIAL arm grid.
#
# MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
# sole acceptance judge and nothing here is one.  LHS is ALWAYS golden
# (Surelog); RHS is ALWAYS ours.  slang was NOT patched; `results/*.csv` were
# READ ONLY; no row was promoted or converted; `GOLDEN_DEFER` stayed unset; the
# four slang-fenced tests are never dispatched by this script.
#
# WHY IT EXISTS.  r10uvm210's own grid (`grid210.sh`, 8 arms) reports
# `ONLY-GOLDEN 0 / ONLY-OURS 0` in the PARSE view for six of eight arms and
# concludes the def-view `param_assign` Rhs FORM table is law-complete.  These
# arms probe the shapes that grid does not build: a package LOCALPARAM chain, an
# INTERFACE listing, a module's own parameter chain, a package CLASS body, a
# BARE (unqualified) cross-package reference through a wildcard import, and a
# wider must-stay-folded control.  Three of them move in the PARSE view.
#
# It also scores the two attempted reproducers of r10uvm210's R0 (`r0_a.sv`,
# `r0_b.sv`) with `ctv210 --tsi`, the measurement R0 itself names.
#
# usage: BIN=<slang-uhdm> OWN=<ct210own> TSI=<ctv210> ./armsv210.sh <armdir> <scratch> <out>
#
# GUARDS: every rc is recorded (verify_golden.py reads a 139 SEGFAULT as
# SLANG_REJECT, RESUME §9), an arm whose golden or ours is missing is printed as
# NO-DATABASE and still counted, `grep -c` never sits in a `set -e` position,
# and the scratch directory is taken from the command line — never hard-coded.
set -u
BIN=${BIN:?path to the slang-uhdm binary under test}
OWN=${OWN:?path to ct210own}
TSI=${TSI:?path to ctv210}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
ARMS=${1:?armdir}; SCR=${2:?scratch}; OUT=${3:?out}
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
[ -x "$OWN" ] || { echo "FATAL: no ct210own $OWN"; exit 3; }
[ -x "$TSI" ] || { echo "FATAL: no ctv210 $TSI"; exit 3; }
mkdir -p "$SCR" || exit 1
: > "$OUT"
n=0; nog=0
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
      echo "ARM $b $ev rc_surelog=$grc rc_ours=$orc VERDICT=NO-DATABASE golden=$([ -f "$g" ] && echo yes || echo NO) ours=$([ -f "$d/ours.uhdm" ] && echo yes || echo NO)" >> "$OUT"
      nog=$((nog+1)); continue
    fi
    "$OWN" --key "$g" G | grep '^K ' | sort > "$d/g.key"; true
    "$OWN" --key "$d/ours.uhdm" O | grep '^K ' | sort > "$d/o.key"; true
    og=$(comm -23 "$d/g.key" "$d/o.key" | wc -l)
    oo=$(comm -13 "$d/g.key" "$d/o.key" | wc -l)
    ag=$(comm -12 "$d/g.key" "$d/o.key" | wc -l)
    # The typespec-Instance multiset, both sides: this is what R0 is about and
    # what the pass's own grid never scored.
    "$TSI" --tsi "$g" | grep '^TSI ' | sort > "$d/g.tsi"; true
    "$TSI" --tsi "$d/ours.uhdm" | grep '^TSI ' | sort > "$d/o.tsi"; true
    tg=$(comm -23 "$d/g.tsi" "$d/o.tsi" | wc -l)
    to=$(comm -13 "$d/g.tsi" "$d/o.tsi" | wc -l)
    tn=$(wc -l < "$d/g.tsi")
    echo "ARM $b $ev rc_surelog=$grc rc_ours=$orc AGREE=$ag ONLY-GOLDEN=$og ONLY-OURS=$oo  TSI-KEYS=$tn TSI-ONLY-GOLDEN=$tg TSI-ONLY-OURS=$to" >> "$OUT"
    comm -23 "$d/g.key" "$d/o.key" | sed "s/^/  G-ONLY $b.$ev /" >> "$OUT"
    comm -13 "$d/g.key" "$d/o.key" | sed "s/^/  O-ONLY $b.$ev /" >> "$OUT"
    comm -23 "$d/g.tsi" "$d/o.tsi" | sed "s/^/  TSI-G-ONLY $b.$ev /" >> "$OUT"
    comm -13 "$d/g.tsi" "$d/o.tsi" | sed "s/^/  TSI-O-ONLY $b.$ev /" >> "$OUT"
    n=$((n+1))
  done
done
{
  echo "-- ARM-VIEWS SCORED: $n   NO-DATABASE: $nog"
  echo "-- NONZERO RCs: $(awk '/^ARM /{for(i=1;i<=NF;i++) if($i ~ /^rc_(surelog|ours)=/ && $i !~ /=0$/) print}' "$OUT" | wc -l)"
  echo "-- TOTAL ONLY-GOLDEN cells: $(awk -F'ONLY-GOLDEN=' '/^ARM /{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
  echo "-- TOTAL ONLY-OURS   cells: $(awk -F'ONLY-OURS=' '/^ARM /{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
} >> "$OUT"
tail -4 "$OUT"
