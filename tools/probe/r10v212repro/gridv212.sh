#!/bin/bash
# r10v212 (VERIFIER) — the adversarial golden grid.  MEASUREMENT ONLY; the
# official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# For every SUBDIRECTORY arm of `gridv/` this runs
#   * the canonical golden-side Surelog — the one `scripts/verify_golden.py`
#     names, `$HOME/git-repos/Surelog/build/bin/surelog` — with `default` mode's
#     argv reproduced (`-parse -sv design.sv -mt 0 -mp 0 -o <w>`), cwd = the arm;
#   * BOTH slang binaries, in BOTH views (definition `--single-unit` and
#     elaborated `--elabuhdm`);
# and prints, per arm and per binary, the clone/base listing census
# (`ct212alias`) and the official `uhdm-cmp` line/head counts against golden.
#
# GUARDS: subdirectory arms found with `find` (a top-level glob runs nothing and
# prints green); the arm list is read on fd 3 and every child gets `</dev/null`;
# PROCESSED is asserted equal to LISTED; scratch is keyed on the arm's RELATIVE
# PATH; EVERY process rc is recorded (rc=139 segfaults otherwise hide); both
# binaries are named by PATH and md5, because both harness scripts silently
# default to the main-tree binary.
#
#   usage: PRIS=<bin> PATCHED=<bin> OUT=<dir> ALIAS=<ct212alias> gridv212.sh
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
PRIS=${PRIS:?set PRIS to the frozen pristine binary}
PATCHED=${PATCHED:?set PATCHED to the frozen patched binary}
OUT=${OUT:?set OUT to the scratch directory for this run}
ALIAS=${ALIAS:?set ALIAS to the built ct212alias}
GRIDDIR=${GRIDDIR:-$HERE/gridv}
for x in "$SL" "$CMP" "$PRIS" "$PATCHED" "$ALIAS"; do
  [ -x "$x" ] || { echo "FATAL: not executable: $x"; exit 3; }
done
echo "SURELOG = $SL"
echo "PRIS    = $PRIS  md5=$(md5sum "$PRIS" | cut -c1-32)"
echo "PATCHED = $PATCHED  md5=$(md5sum "$PATCHED" | cut -c1-32)"
echo "GRIDDIR = $GRIDDIR"
mkdir -p "$OUT" || exit 1
LIST=$OUT/arms.txt
find "$GRIDDIR" -mindepth 1 -maxdepth 1 -type d | sort > "$LIST"
listed=$(grep -c . "$LIST" || true)
echo "LISTED=$listed"
[ "$listed" -gt 0 ] || { echo "GATE FAIL: no arms under $GRIDDIR"; exit 4; }
proc=0
while read -r arm <&3; do
  rel=${arm#$GRIDDIR/}
  key=$(echo "$rel" | tr '/' '_')
  W=$OUT/$key
  mkdir -p "$W"
  ( cd "$arm" && "$SL" -parse -sv design.sv -mt 0 -mp 0 -o "$W" \
        > "$W/surelog.log" 2>&1 </dev/null ); grc=$?
  G=$(ls "$W"/slpp_all/*.uhdm "$W"/slpp_unit/*.uhdm 2>/dev/null | head -1)
  ( cd "$arm" && "$PRIS"    --single-unit design.sv -o "$W/pd.uhdm" > "$W/pd.log" 2>&1 </dev/null ); pdrc=$?
  ( cd "$arm" && "$PATCHED" --single-unit design.sv -o "$W/qd.uhdm" > "$W/qd.log" 2>&1 </dev/null ); qdrc=$?
  ( cd "$arm" && "$PRIS"    --elabuhdm   design.sv -o "$W/pe.uhdm" > "$W/pe.log" 2>&1 </dev/null ); perc=$?
  ( cd "$arm" && "$PATCHED" --elabuhdm   design.sv -o "$W/qe.uhdm" > "$W/qe.log" 2>&1 </dev/null ); qerc=$?
  gm="-"; pm="-"; qm="-"
  if [ -n "$G" ] && [ -f "$G" ]; then
    "$ALIAS" "$G" > "$W/g.alias" 2>&1
    gm=$(sed -n '1s/.*MISMATCHES=//p' "$W/g.alias")
  fi
  [ -f "$W/pd.uhdm" ] && { "$ALIAS" "$W/pd.uhdm" > "$W/pd.alias" 2>&1; pm=$(sed -n '1s/.*MISMATCHES=//p' "$W/pd.alias"); }
  [ -f "$W/qd.uhdm" ] && { "$ALIAS" "$W/qd.uhdm" > "$W/qd.alias" 2>&1; qm=$(sed -n '1s/.*MISMATCHES=//p' "$W/qd.alias"); }
  # official judge, both views, both binaries
  cl() { # <golden> <ours> <tag>
    if [ -n "$G" ] && [ -f "$G" ] && [ -f "$2" ]; then
      "$CMP" "$G" "$2" > "$W/$3.cmp" 2> "$W/$3.head"
      local a b
      a=$(grep -c . "$W/$3.cmp") || a=0
      b=$(grep -c '^LHS:' "$W/$3.head") || b=0
      echo "$a/$b"
    else echo "-/-"; fi
  }
  pdc=$(cl "$G" "$W/pd.uhdm" pdcmp); qdc=$(cl "$G" "$W/qd.uhdm" qdcmp)
  pec=$(cl "$G" "$W/pe.uhdm" pecmp); qec=$(cl "$G" "$W/qe.uhdm" qecmp)
  printf "ARM %-24s slrc=%-3s gdb=%-3s | aliasMISMATCH g=%-3s pris=%-3s pat=%-3s | cmp def pris=%-9s pat=%-9s | cmp elab pris=%-9s pat=%-9s | rc %s/%s/%s/%s\n" \
    "$rel" "$grc" "$([ -n "$G" ] && echo yes || echo NO)" "$gm" "$pm" "$qm" \
    "$pdc" "$qdc" "$pec" "$qec" "$pdrc" "$qdrc" "$perc" "$qerc"
  proc=$((proc+1))
done 3< "$LIST"
echo "PROCESSED=$proc LISTED=$listed"
[ "$proc" -eq "$listed" ] || { echo "GATE FAIL: PROCESSED != LISTED"; exit 4; }
echo "GRIDV OK"
