#!/bin/bash
# usage: BINS="name=path[=VAR] ..." [TOP=<top>] grid.sh <out.tsv> <casedir>...  (v11u448: adapted from r11u448repro/drivers/grid.sh, TOP adds --top-module / --top)
# copies each case dut.sv to $WR/<repro>_<GROUP>_<case>/ (default WR=/tmp/v11u448_grid), keyed on the full repro path
# golden: surelog -parse -nobuiltin -nocache -sv dut.sv; ours: dut.sv --single-unit --nobuiltin
# (each binary run with VAR=1 in its environment when a third field is given)
SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
SC=${SC:-/tmp/v11u448_bin/uhdm-strictcmp}
UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
for t in "$SURELOG" "$UHDM_CMP" "$SC" "$UHDM_DUMP"; do [ -x "$t" ] || { echo "missing $t"; exit 2; }; done
WR=${WR:-/tmp/v11u448_grid}
out=$1; shift
: > $out
for c in "$@"; do
  c=$(readlink -f $c); key="$(echo $c | sed "s|.*/tools/probe/||; s|/cases/|/|")"
  d=$WR/$(echo $key | tr / _)${TOP:+_top}; mkdir -p $d
  if ! cmp -s $c/dut.sv $d/dut.sv; then rm -rf $d/golden $d/golden.rc $d/gdump.txt; cp $c/dut.sv $d/dut.sv; fi
  if [ ! -s $d/golden/slpp_all/surelog.uhdm ]; then
    rm -rf $d/golden $d/gdump.txt; (cd $d && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv ${TOP:+--top-module $TOP} dut.sv -mt 0 -mp 0 -o golden >/dev/null 2>&1 </dev/null); echo $? > $d/golden.rc
  fi
  line="$key	slrc=$(cat $d/golden.rc)"
  for nb in $BINS; do
    IFS='=' read -r n b v <<< "$nb"; [ -x "$b" ] || { echo "missing $b"; exit 2; }
    rm -f $d/out_$n.uhdm
    if [ -n "$v" ]; then (cd $d && timeout 300 env $v=1 $ENVX $b dut.sv --single-unit --nobuiltin ${TOP:+--top $TOP} -o out_$n.uhdm >/dev/null 2>$d/err_$n.txt </dev/null); rc=$?
    else (cd $d && timeout 300 env $ENVX $b dut.sv --single-unit --nobuiltin ${TOP:+--top $TOP} -o out_$n.uhdm >/dev/null 2>$d/err_$n.txt </dev/null); rc=$?; fi
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
  echo "$line" >> $out
done
