#!/bin/bash
# distv108.sh <arm-out-dir> <tagA> <tagB>: dumps gold/A/B (cached), prints
#   byteSame(A,B)  dumpdiff(A,B)  dist(gold,A)  dist(gold,B)  (order-blind: sorted, id/path-normalised)
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
w=${1:?}; a=${2:?}; b=${3:?}
norm(){ sed -E 's/, id:[0-9]+//; s#file:[^,]*,##' ; }
for t in gold $a $b; do [ -s "$w/$t.dump" ] || timeout 300 $D "$w/$t.uhdm" 2>/dev/null | norm > "$w/$t.dump"; done
same=$(cmp -s "$w/$a.uhdm" "$w/$b.uhdm" && echo SAME || echo MOVED)
dd=$(diff <(sort "$w/$a.dump") <(sort "$w/$b.dump") | grep -c '^[<>]'; true)
ga=$(diff <(sort "$w/gold.dump") <(sort "$w/$a.dump") | grep -c '^[<>]'; true)
gb=$(diff <(sort "$w/gold.dump") <(sort "$w/$b.dump") | grep -c '^[<>]'; true)
echo "$same dd=$dd dist_$a=$ga dist_$b=$gb"
