#!/usr/bin/env bash
# vrgg10 adversarial cell: golden + base + patched, judged by the OFFICIAL uhdm-cmp.
set -u
d=$1; BASE=$2; PAT=$3
n=$(basename "$d")
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
rm -rf "$d/sl" "$d/base.uhdm" "$d/pat.uhdm" "$d/cmp_base.txt" "$d/cmp_pat.txt"
( cd "$d" && "$SURELOG" -parse top.sv -mt 0 -mp 0 -o "$d/sl" >"$d/sl.log" 2>&1 </dev/null ); grc=$?
( cd "$d" && "$BASE" top.sv --single-unit -o "$d/base.uhdm" >"$d/base.log" 2>&1 </dev/null ); brc=$?
( cd "$d" && "$PAT"  top.sv --single-unit -o "$d/pat.uhdm"  >"$d/pat.log"  2>&1 </dev/null ); prc=$?
g=$d/sl/slpp_all/surelog.uhdm
if [ ! -f "$g" ]; then echo "$n NODB grc=$grc brc=$brc prc=$prc"; exit 0; fi
if [ ! -f "$d/base.uhdm" ] || [ ! -f "$d/pat.uhdm" ]; then
  echo "$n NOSLANG grc=$grc brc=$brc prc=$prc"; exit 0; fi
"$CMP" "$g" "$d/base.uhdm" >"$d/cmp_base.txt" 2>"$d/cmp_base.err"; bc=$?
"$CMP" "$g" "$d/pat.uhdm"  >"$d/cmp_pat.txt"  2>"$d/cmp_pat.err";  pc=$?
bl=$(wc -l < "$d/cmp_base.txt"); pl=$(wc -l < "$d/cmp_pat.txt")
bm=$(md5sum < "$d/base.uhdm" | cut -c1-12); pm=$(md5sum < "$d/pat.uhdm" | cut -c1-12)
same=SAME; [ "$bm" = "$pm" ] || same=MOVER
verdict=SAME
if [ "$bl" -gt "$pl" ]; then verdict=FIXED
elif [ "$pl" -gt "$bl" ]; then verdict=BROKEN
elif [ "$same" = MOVER ]; then
  if diff -q "$d/cmp_base.txt" "$d/cmp_pat.txt" >/dev/null; then verdict=MOVER_CMPEQ; else verdict=MOVER_CMPDIFF; fi
fi
echo "$n $verdict $same brc=$brc prc=$prc cmpbase=$bc/$bl cmppat=$pc/$pl"
