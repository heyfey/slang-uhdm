#!/bin/bash
# usage: movers.sh <census.tsv> <out.tsv>: for each MOVED row, a Surelog golden of the copied
# source, then uhdm-cmp lines, path-normalized dump distance and the strict verdict for p and l
SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
C=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
SC=/home/heyfey/git-repos/slang-uhdm/build/uhdm-strictcmp
DU=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
for t in $SURELOG $C $SC $DU; do [ -x "$t" ] || { echo missing $t; exit 2; }; done
WR=${WR:-/tmp/v11u439_cen}; : > $2
awk -F'\t' '$5=="MOVED"{print $1"\t"$2}' $1 | while IFS=$'\t' read n f; do
  d=$WR/$n
  [ -s $d/golden/slpp_all/surelog.uhdm ] || (cd $d && rm -rf golden && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o golden >/dev/null 2>&1 </dev/null)
  g=$d/golden/slpp_all/surelog.uhdm; line="$n	$f"
  if [ -s $g ]; then
    $DU $g 2>/dev/null | sed 1d | sed "s#$d/##g; s#, id:[0-9]*##g" > $d/gdump.txt
    for b in p l; do
      cc=$($C $g $d/$b.uhdm 2>&1 | wc -l); s=$($SC $g $d/$b.uhdm 2>&1 | tail -1)
      $DU $d/$b.uhdm 2>/dev/null | sed 1d | sed "s#$d/##g; s#, id:[0-9]*##g" > $d/dump_$b.txt
      dd=$(diff $d/gdump.txt $d/dump_$b.txt | grep -c '^[<>]')
      line="$line	$b:cmp=$cc dist=$dd [$s]"
    done
  else line="$line	NOGOLDEN"; fi
  echo "$line" >> $2
done
