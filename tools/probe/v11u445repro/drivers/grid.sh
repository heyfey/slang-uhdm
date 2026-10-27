#!/bin/bash
# usage: grid.sh <out.tsv> <casedir>... ; env BINS="name=path ..." ; ENVX="VAR=1 ..." optional
# copies each case's dut.sv to $WR/<GROUP>_<case>/ (default WR=/tmp/v11u445_grid) and runs there
SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
SC=/tmp/v11u445_bin/uhdm-strictcmp
UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
for t in "$SURELOG" "$UHDM_CMP" "$SC" "$UHDM_DUMP"; do [ -x "$t" ] || { echo "missing $t"; exit 2; }; done
WR=${WR:-/tmp/v11u445_grid}
out=$1; shift
: > $out
for c in "$@"; do
  c=$(readlink -f $c); key="$(basename $(dirname $c))/$(basename $c)"
  d=$WR/$(echo $key | tr / _); mkdir -p $d
  if ! cmp -s $c/dut.sv $d/dut.sv; then rm -rf $d/golden $d/golden.rc $d/gdump.txt; cp $c/dut.sv $d/dut.sv; fi
  if [ ! -s $d/golden/slpp_all/surelog.uhdm ]; then
    rm -rf $d/golden $d/gdump.txt; (cd $d && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o golden >/dev/null 2>&1 </dev/null); echo $? > $d/golden.rc
  fi
  line="$key	slrc=$(cat $d/golden.rc)"
  for nb in $BINS; do
    n=${nb%%=*}; b=${nb#*=}; [ -x "$b" ] || { echo "missing $b"; exit 2; }
    rm -f $d/out_$n.uhdm
    (cd $d && timeout 300 env $ENVX $b dut.sv --single-unit --nobuiltin -o out_$n.uhdm >/dev/null 2>$d/err_$n.txt </dev/null); rc=$?
    md=$(md5sum < $d/out_$n.uhdm 2>/dev/null | cut -c1-8)
    if [ -s $d/golden/slpp_all/surelog.uhdm ] && [ -s $d/out_$n.uhdm ]; then
      cc=$($UHDM_CMP $d/golden/slpp_all/surelog.uhdm $d/out_$n.uhdm 2>&1 | wc -l)
      s=$($SC $d/golden/slpp_all/surelog.uhdm $d/out_$n.uhdm 2>&1 | tail -1)
      [ -s $d/gdump.txt ] || $UHDM_DUMP $d/golden/slpp_all/surelog.uhdm 2>/dev/null | sed 1d | sed "s#$d/##g; s#, id:[0-9]*##g" > $d/gdump.txt
      $UHDM_DUMP $d/out_$n.uhdm 2>/dev/null | sed 1d | sed "s#$d/##g; s#, id:[0-9]*##g" > $d/dump_$n.txt
      dd=$(diff $d/gdump.txt $d/dump_$n.txt | grep -c '^[<>]')
    else cc=NA; s=NA; dd=NA; fi
    line="$line	$n:rc=$rc cmp=$cc dist=$dd md5=$md [$s]"
  done
  echo "$line" | tee -a $out
done
