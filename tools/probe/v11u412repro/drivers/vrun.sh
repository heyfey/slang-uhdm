#!/bin/bash
# vrun.sh <casedir> [bi=0|1] : golden + pristine + law ; prints one line
c=$1; bi=${2:-0}
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
SC=/tmp/wt_v11u412/build/uhdm-strictcmp
P=/tmp/v11u412_bin/pristine; L=/tmp/v11u412_bin/law
nbS="-nobuiltin"; nbO="--nobuiltin"; [ "$bi" = 1 ] && { nbS=""; nbO=""; }
rel=${c#/tmp/v11u412_cases/}
h=$(cat $c/*.sv | md5sum | cut -c1-12)$bi
gd=/tmp/v11u412_gold/$h
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then
  rm -rf $gd; mkdir -p $gd; cp $c/*.sv $gd/
  (cd $gd && timeout 300 $SL -parse $nbS -nocache -sv dut.sv > sl.log 2>&1)
fi
norm(){ sed -E 's/, id:[0-9]+//; s#file:[^,]*/##; s#[^ ]*/dut\.sv#dut.sv#g'; }
G=$gd/slpp_all/surelog.uhdm
[ -f $gd/g.txt ] || $D $G 2>/dev/null | norm > $gd/g.txt
out=""
for t in p l ${EXTRA_TAGS}; do
  o=/tmp/v11u412_out/$rel/$t; rm -rf $o; mkdir -p $o
  case $t in p) B=$P; E="";; l) B=$L; E="";; *) B=$L; E="$(eval echo \$ENV_$t)";; esac
  (cd $c && env $E timeout 300 $B dut.sv --single-unit $nbO -o $o/ours.uhdm > $o/ours.log 2>&1; echo $? > $o/rc)
  rc=$(cat $o/rc)
  if [ ! -f $G ]; then out="$out | $t rc=$rc NOGOLDEN"; continue; fi
  if [ ! -s $o/ours.uhdm ]; then out="$out | $t rc=$rc NOUHDM"; continue; fi
  n=$($CMP $G $o/ours.uhdm 2>&1 | wc -l)
  s=$($SC $G $o/ours.uhdm 2>&1 | tail -1 | awk '{print $1}')
  $D $o/ours.uhdm 2>/dev/null | norm > $o/s.txt
  dl=$(diff $gd/g.txt $o/s.txt | grep -c '^[<>]')
  m=$(md5sum < $o/ours.uhdm | cut -c1-8)
  out="$out | $t rc=$rc cmp=$n $s d=$dl $m"
done
echo "$rel$out"
