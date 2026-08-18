#!/usr/bin/env bash
# vrgg13 adversarial arm runner: builds golden (surelog), base and patched
# databases per cell in BOTH views (default + -elabuhdm), cmps and censuses.
#   usage: runarms.sh <armsdir> <outdir>
set -u
AD=${1:?arms}; OUT=${2:?out}
SL=$HOME/git-repos/Surelog/build/bin/surelog
BASE=/tmp/vrgg13_bin/slang-uhdm-base
PAT=/tmp/vrgg13_bin/slang-uhdm-pat
CEN=/tmp/vrgg13_acensus
mkdir -p "$OUT"
: > "$OUT/golden.cen"; : > "$OUT/base.cen"; : > "$OUT/pat.cen"
: > "$OUT/goldenE.cen"; : > "$OUT/baseE.cen"; : > "$OUT/patE.cen"
: > "$OUT/summary.txt"
ok=0; nodb=0; noslang=0
for d in "$AD"/*/; do
  c=$(basename "$d")
  ( cd "$d" && rm -rf slpp_all
    # DEFAULT view
    [ -f golden.uhdm ] || { "$SL" -parse -mt 0 -mp 0 top.sv > sl.log 2>&1; [ -f slpp_all/surelog.uhdm ] && cp slpp_all/surelog.uhdm golden.uhdm; }
    rm -rf slpp_all
    # ELAB view (-elabuhdm on both sides)
    [ -f goldenE.uhdm ] || { "$SL" -parse -elabuhdm -mt 0 -mp 0 top.sv > slE.log 2>&1; [ -f slpp_all/surelog.uhdm ] && cp slpp_all/surelog.uhdm goldenE.uhdm; }
    rm -rf slpp_all
    "$BASE" top.sv --single-unit -o base.uhdm  > b.log  2>&1; echo $? > base.rc
    "$PAT"  top.sv --single-unit -o pat.uhdm   > p.log  2>&1; echo $? > pat.rc
    "$BASE" top.sv --single-unit --elabuhdm -o baseE.uhdm > bE.log 2>&1; echo $? > baseE.rc
    "$PAT"  top.sv --single-unit --elabuhdm -o patE.uhdm  > pE.log 2>&1; echo $? > patE.rc
    rm -rf slpp_all )
  brc=$(cat "$d/base.rc" 2>/dev/null||echo 99); prc=$(cat "$d/pat.rc" 2>/dev/null||echo 99)
  bErc=$(cat "$d/baseE.rc" 2>/dev/null||echo 99); pErc=$(cat "$d/patE.rc" 2>/dev/null||echo 99)
  if [ ! -f "$d/golden.uhdm" ] || [ ! -f "$d/base.uhdm" ] || [ ! -f "$d/pat.uhdm" ]; then
    echo "NODB $c baserc=$brc patrc=$prc" | tee -a "$OUT/summary.txt"; nodb=$((nodb+1)); continue
  fi
  for r in "$brc" "$prc" "$bErc" "$pErc"; do [ "$r" != 0 ] && { echo "NONZERO-RC $c b=$brc p=$prc bE=$bErc pE=$pErc" | tee -a "$OUT/summary.txt"; noslang=$((noslang+1)); break; }; done
  bl=$($HOME/.local/bin/uhdm-cmp "$d/golden.uhdm" "$d/base.uhdm" 2>&1 | tee "$d/cmp_base.txt" | wc -l)
  pl=$($HOME/.local/bin/uhdm-cmp "$d/golden.uhdm" "$d/pat.uhdm"  2>&1 | tee "$d/cmp_pat.txt"  | wc -l)
  bh=$(grep -c '^LHS:' "$d/cmp_base.txt"; true); ph=$(grep -c '^LHS:' "$d/cmp_pat.txt"; true)
  bEl=0; pEl=0; bEh=0; pEh=0
  if [ -f "$d/goldenE.uhdm" ] && [ -f "$d/baseE.uhdm" ] && [ -f "$d/patE.uhdm" ]; then
    bEl=$($HOME/.local/bin/uhdm-cmp "$d/goldenE.uhdm" "$d/baseE.uhdm" 2>&1 | tee "$d/cmpE_base.txt" | wc -l)
    pEl=$($HOME/.local/bin/uhdm-cmp "$d/goldenE.uhdm" "$d/patE.uhdm"  2>&1 | tee "$d/cmpE_pat.txt"  | wc -l)
    bEh=$(grep -c '^LHS:' "$d/cmpE_base.txt"; true); pEh=$(grep -c '^LHS:' "$d/cmpE_pat.txt"; true)
    "$CEN" "$d/goldenE.uhdm" 2>/dev/null | sed "s#^#$c\t#" >> "$OUT/goldenE.cen"
    "$CEN" "$d/baseE.uhdm"   2>/dev/null | sed "s#^#$c\t#" >> "$OUT/baseE.cen"
    "$CEN" "$d/patE.uhdm"    2>/dev/null | sed "s#^#$c\t#" >> "$OUT/patE.cen"
  fi
  "$CEN" "$d/golden.uhdm" 2>/dev/null | sed "s#^#$c\t#" >> "$OUT/golden.cen"
  "$CEN" "$d/base.uhdm"   2>/dev/null | sed "s#^#$c\t#" >> "$OUT/base.cen"
  "$CEN" "$d/pat.uhdm"    2>/dev/null | sed "s#^#$c\t#" >> "$OUT/pat.cen"
  vd=""; [ "$bl" != "$pl" ] && vd="  <<< CMPDELTA def $bl->$pl"
  ve=""; [ "$bEl" != "$pEl" ] && ve="  <<< CMPDELTA elab $bEl->$pEl"
  echo "$c def base=$bl/$bh pat=$pl/$ph | elab base=$bEl/$bEh pat=$pEl/$pEh$vd$ve" | tee -a "$OUT/summary.txt"
  ok=$((ok+1))
done
echo "-- cells=$ok NODB=$nodb NONZERO-RC=$noslang" | tee -a "$OUT/summary.txt"
