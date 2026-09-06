#!/usr/bin/env bash
# r10earl105 GRID DRIVER — MEASUREMENT ONLY.
#   PATCHED_BIN=<bin> PRISTINE_BIN=<bin> bash grid105.sh <outdir> [arm.sv ...]
# For every arm x {plain, elab}: build the Surelog GOLDEN here, build BOTH
# frozen binaries, print uhdm-cmp lines/heads for each and the cen105 THREE-WAY
# score (AWAY-GOLDEN / MOVED-WRONG / TO-GOLDEN) of patched against pristine
# against golden.  The census is what the law is written from; the official
# uhdm-cmp is the judge.
#
# GUARDS: every producer's rc is recorded; a missing database is printed as
# REJECT and COUNTED, never silently skipped; children get </dev/null so no
# child can eat the arm list; the -top each arm needs is read from TOPS.txt
# (kept OUT of the .sv so the committed arms stay byte-identical to the ones
# the wide boundary measured) so the driver cannot be run with the wrong root.
set -u
PAT=${PATCHED_BIN:?set PATCHED_BIN}; PRIS=${PRISTINE_BIN:?set PRISTINE_BIN}
CEN=${CEN_BIN:-/tmp/r10earl105_cen105}
SCORE=$(cd "$(dirname "$0")" && pwd)/score105.py
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${1:?outdir}; shift
mkdir -p "$OUT"
FILES=("$@"); [ ${#FILES[@]} -eq 0 ] && FILES=("$HERE"/[gh]?_*105.sv)
printf '%-18s %-6s %5s %5s %5s %10s %10s   %s\n' ARM VIEW SLRC PRC ARC "PRIS c/h" "PATCH c/h" SCORE
for f0 in "${FILES[@]}"; do
  f=$f0; case "$f" in /*) ;; *) f="$HERE/$f0";; esac
  [ -f "$f" ] || continue
  arm=$(basename "$f" .sv)
  T=""; t=$(awk -v a="$arm" '$1==a{print $2}' "$HERE/TOPS.txt" | head -1); [ -n "$t" ] && T="-top $t"
  U=""; [ -n "$t" ] && U="--top $t"
  for view in plain elab; do
    case $view in plain) SLF="-parse"; SUF="";; elab) SLF="-parse -elabuhdm"; SUF="--elabuhdm";; esac
    d="$OUT/${arm}_${view}"; mkdir -p "$d"; rm -rf "$d/sl"
    $SL $SLF -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o "$d/sl" $T "$f" > "$d/sl.log" 2>&1 </dev/null
    slrc=$?
    G=$(find "$d/sl" -name '*.uhdm' 2>/dev/null | head -1)
    ( cd "$d" && "$PRIS" $SUF $U "$f" --nobuiltin -o pris.uhdm    > p.log 2>&1 </dev/null ); prc=$?
    ( cd "$d" && "$PAT"  $SUF $U "$f" --nobuiltin -o patched.uhdm > a.log 2>&1 </dev/null ); arc=$?
    if [ -z "${G:-}" ] || [ ! -f "$G" ] || [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/patched.uhdm" ]; then
      printf '%-18s %-6s %5s %5s %5s %10s %10s   %s\n' "$arm" "$view" "$slrc" "$prc" "$arc" - - REJECT; continue; fi
    cp "$G" "$d/golden.uhdm"
    pl=$($CMP "$G" "$d/pris.uhdm" 2>/dev/null|wc -l);    ph=$($CMP "$G" "$d/pris.uhdm" 2>&1 >/dev/null|grep -c '^LHS:'||true)
    al=$($CMP "$G" "$d/patched.uhdm" 2>/dev/null|wc -l); ah=$($CMP "$G" "$d/patched.uhdm" 2>&1 >/dev/null|grep -c '^LHS:'||true)
    "$CEN" "$G" "$d/pris.uhdm"    --all > "$d/cenP.txt" 2>&1
    "$CEN" "$G" "$d/patched.uhdm" --all > "$d/cenA.txt" 2>&1
    awk '/^CELL|^ONLY-/{print "x\t" $0}' "$d/cenP.txt" > "$d/cenP.tsv"
    awk '/^CELL|^ONLY-/{print "x\t" $0}' "$d/cenA.txt" > "$d/cenA.tsv"
    S=$(python3 "$SCORE" "$d/cenP.tsv" "$d/cenA.tsv" 2>&1 | awk '/^  (AWAY|MOVED|TO-GOLDEN|UNREACH|ADDED|REMOVED)/{printf "%s=%s ", $1, $2} /REFUSING|GOLDEN-MOVED/{printf "GOLDEN-MOVED "}')
    printf '%-18s %-6s %5s %5s %5s %10s %10s   %s\n' "$arm" "$view" "$slrc" "$prc" "$arc" "$pl/$ph" "$al/$ah" "$S"
  done
done
