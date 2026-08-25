#!/bin/bash
# r10uvm128/arm128.sh — MEASUREMENT ONLY.  Runs one grid arm through Surelog
# (LHS, always golden) and through BOTH of this pass's frozen binaries (RHS),
# in the DEF and ELAB views, and scores each with `score128.py`.
#
# GUARDS: both binaries are named on the command line and PRINTED with their
# md5 (neither `verify_golden.py` nor `check_goldens.sh` is involved, and
# nothing may default to a main-tree binary); every scratch dir is keyed on the
# arm's RELATIVE path; each child gets </dev/null; the per-cell rc is RECORDED,
# because a segfault otherwise reads as "no rows moved".
set -u
ARM=${1:?arm .sv}
PRI=${PRI:?pristine binary}
PAT=${PAT:?patched binary}
WD=${AWD:-/tmp/r10uvm128_arms}/$(basename "$ARM" .sv)
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
SC=$(dirname "$0")/score128.py
rm -rf "$WD"; mkdir -p "$WD" || exit 9
cp "$ARM" "$WD"/ || exit 9
# the arm's macro definitions live in their own file ON PURPOSE (see the header
# of g128_defs.svh) — carry it along.
[ -f "$(dirname "$ARM")/g128_defs.svh" ] && cp "$(dirname "$ARM")/g128_defs.svh" "$WD"/
leaf=$(basename "$ARM")
echo "ARM $leaf"
echo "  PRI $(md5sum "$PRI" | cut -c1-32)  PAT $(md5sum "$PAT" | cut -c1-32)"
for m in def elab; do
  fl=""; [ $m = elab ] && fl="-elabuhdm"
  slfl=""; [ $m = elab ] && slfl="-elabuhdm"
  ( cd "$WD" && "$SL" -parse -nonote -noinfo -nobuiltin $slfl -d uhdm "$leaf" > sl_$m.log 2>&1 </dev/null )
  slrc=$?
  g=$WD/slpp_all/surelog.uhdm
  [ -f "$g" ] || { echo "  $m: NO GOLDEN (surelog rc=$slrc)"; continue; }
  cp "$g" "$WD/gold_$m.uhdm"
  ( cd "$WD" && "$PRI" $fl "$leaf" -o pris_$m.uhdm > pris_$m.log 2>&1 </dev/null ); prc=$?
  ( cd "$WD" && "$PAT" $fl "$leaf" -o pat_$m.uhdm  > pat_$m.log  2>&1 </dev/null ); qrc=$?
  for f in gold pris pat; do
    [ -f "$WD/${f}_$m.uhdm" ] && "$DUMP" "$WD/${f}_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$WD/${f}_$m.dump"
  done
  [ -f "$WD/pris_$m.dump" ] && [ -f "$WD/pat_$m.dump" ] || { echo "  $m: MISSING DUMP (pris rc=$prc pat rc=$qrc)"; continue; }
  echo "  $m  pris rc=$prc  pat rc=$qrc"
  echo "    PRIS $(python3 "$SC" -c "$WD/gold_$m.dump" "$WD/pris_$m.dump" | head -1)"
  echo "    PAT  $(python3 "$SC" -c "$WD/gold_$m.dump" "$WD/pat_$m.dump"  | head -1)"
  python3 "$SC" -c "$WD/gold_$m.dump" "$WD/pris_$m.dump" | tail -n +2 > "$WD/score_pris_$m.txt"
  python3 "$SC" -c "$WD/gold_$m.dump" "$WD/pat_$m.dump"  | tail -n +2 > "$WD/score_pat_$m.txt"
  d=$(diff "$WD/score_pris_$m.txt" "$WD/score_pat_$m.txt" | grep -cE '^[<>]'; true)
  echo "    CELLS MOVED BY THE PATCH: $d"
  rm -rf "$WD/slpp_all" "$WD/slpp_unit"
done
