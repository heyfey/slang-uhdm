#!/bin/bash
# v3.sh <casedir> [bi]: verified binary + R11V412_OFF (== law?) + R11U412_OFF (== pristine?)
c=$1; bi=${2:-0}
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
SC=/tmp/wt_v11u412/build/uhdm-strictcmp; V=/tmp/v11u412_bin/verified
nbO="--nobuiltin"; [ "$bi" = 1 ] && nbO=""
rel=${c#/tmp/v11u412_cases/}; h=$(cat $c/*.sv | md5sum | cut -c1-12)$bi; gd=/tmp/v11u412_gold/$h; G=$gd/slpp_all/surelog.uhdm
norm(){ sed -E 's/, id:[0-9]+//; s#file:[^,]*/##; s#[^ ]*/dut\.sv#dut.sv#g'; }
out=""
for t in v vo uo; do
  o=/tmp/v11u412_out/$rel/$t; rm -rf $o; mkdir -p $o
  case $t in v) E="X412=1";; vo) E="R11V412_OFF=1";; uo) E="R11U412_OFF=1";; esac
  (cd $c && env $E timeout 300 $V dut.sv --single-unit $nbO -o $o/ours.uhdm > $o/ours.log 2>&1; echo $? > $o/rc)
  rc=$(cat $o/rc); m=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-8)
  if [ $t = v ] && [ -f $G ] && [ -s $o/ours.uhdm ]; then
    n=$($CMP $G $o/ours.uhdm 2>&1 | wc -l); s=$($SC $G $o/ours.uhdm 2>&1 | tail -1 | awk '{print $1}')
    $D $o/ours.uhdm 2>/dev/null | norm > $o/s.txt; dl=$(diff $gd/g.txt $o/s.txt | grep -c '^[<>]')
    out="$out | v rc=$rc cmp=$n $s d=$dl $m"
  else out="$out | $t rc=$rc $m"; fi
done
ml=$(md5sum < /tmp/v11u412_out/$rel/l/ours.uhdm 2>/dev/null | cut -c1-8); mp=$(md5sum < /tmp/v11u412_out/$rel/p/ours.uhdm 2>/dev/null | cut -c1-8)
mvo=$(md5sum < /tmp/v11u412_out/$rel/vo/ours.uhdm 2>/dev/null | cut -c1-8); muo=$(md5sum < /tmp/v11u412_out/$rel/uo/ours.uhdm 2>/dev/null | cut -c1-8)
echo "$rel$out | R11V412_OFF==law $([ "$mvo" = "$ml" ] && echo yes || echo NO) | R11U412_OFF==pristine $([ "$muo" = "$mp" ] && echo yes || echo NO)"
