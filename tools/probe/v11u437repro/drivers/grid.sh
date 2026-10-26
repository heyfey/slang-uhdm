#!/bin/bash
# usage: grid.sh <out.tsv> <casedir>... ; env BINS="name=path ..." ENVX="VAR=1 ..." ; outputs out_<name>.uhdm in each case dir
SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
SC=/tmp/wt_v11u437/build/uhdm-strictcmp
for t in "$SURELOG" "$UHDM_CMP" "$SC"; do [ -x "$t" ] || { echo "missing $t"; exit 2; }; done
out=$1; shift
: > $out
for d in "$@"; do
  d=$(readlink -f $d)
  if [ ! -s $d/golden/slpp_all/surelog.uhdm ] && [ ! -f $d/golden.rc ]; then
    rm -rf $d/golden; (cd $d && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o golden >/dev/null 2>&1 </dev/null); echo $? > $d/golden.rc
  fi
  line="$(basename $(dirname $d))/$(basename $d)	slrc=$(cat $d/golden.rc)"
  for nb in $BINS; do
    n=${nb%%=*}; b=${nb#*=}; [ -x "$b" ] || { echo "missing $b"; exit 2; }
    rm -f $d/out_$n.uhdm
    (cd $d && timeout 300 env $ENVX $b dut.sv --single-unit --nobuiltin -o out_$n.uhdm >/dev/null 2>$d/err_$n.txt </dev/null); rc=$?
    md=$(md5sum < $d/out_$n.uhdm 2>/dev/null | cut -c1-8)
    if [ -s $d/golden/slpp_all/surelog.uhdm ] && [ -s $d/out_$n.uhdm ]; then
      c=$($UHDM_CMP $d/golden/slpp_all/surelog.uhdm $d/out_$n.uhdm 2>&1 | wc -l)
      s=$($SC --dump-a $d/g.txt --dump-b $d/o_$n.txt $d/golden/slpp_all/surelog.uhdm $d/out_$n.uhdm 2>&1 | tail -1)
    else c=NA; s=NA; fi
    line="$line	$n:rc=$rc cmp=$c md5=$md [$s]"
  done
  echo "$line" >> $out
done
