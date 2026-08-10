#!/bin/bash
# bndd25.sh <baseTag> <newTag> -- the BIND-RESIDUE diff between two bnd25 runs.
# Residue = every census row where G != O.  The counts are the metric: a law
# that removes a wrong bind shrinks the O=<x> G=- side, one that adds a missing
# bind shrinks the O=- G=<x> side, and NEITHER may grow.
res() {
  grep -v absent "$1" | awk '{g="";o=""; for(i=1;i<=NF;i++){if($i ~ /^G=/)g=$i; if($i ~ /^O=/)o=$i} if(g!=""&&o!=""&&substr(g,3)!=substr(o,3)) print}'
}
res "/tmp/r10earl25_bnd_$1.txt" > "/tmp/r10earl25_bres_$1.txt"
res "/tmp/r10earl25_bnd_$2.txt" > "/tmp/r10earl25_bres_$2.txt"
echo "residue rows: $1=$(wc -l < "/tmp/r10earl25_bres_$1.txt")  $2=$(wc -l < "/tmp/r10earl25_bres_$2.txt")"
echo "--- $1 shapes"
sed -E 's/^[^ ]+ +//' "/tmp/r10earl25_bres_$1.txt" | awk '{print $(NF-1), $NF}' | sort | uniq -c | sort -rn
echo "--- $2 shapes"
sed -E 's/^[^ ]+ +//' "/tmp/r10earl25_bres_$2.txt" | awk '{print $(NF-1), $NF}' | sort | uniq -c | sort -rn
echo "--- row-set diff (< = only in $1, > = only in $2)"
sort "/tmp/r10earl25_bres_$1.txt" > /tmp/r10earl25_bs1.txt
sort "/tmp/r10earl25_bres_$2.txt" > /tmp/r10earl25_bs2.txt
diff /tmp/r10earl25_bs1.txt /tmp/r10earl25_bs2.txt | head -60
echo "(rc=$?)"
