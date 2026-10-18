#!/bin/bash
# vswitch.sh <casesroot> <law> <verified> : per case, does R11V402_OFF (and each single V switch) on the verified binary give the law binary's bytes and exit code?
R=$1; L=$2; F=$3
for c in $(cd $R && find . -name dut.sv | sort); do rel=${c#./}; rel=${rel%/dut.sv}; w=/tmp/v11u402_vs/$(echo $rel | tr / _); rm -rf $w; mkdir -p $w; cp $R/$rel/*.sv $w/; cd $w
  run(){ rm -f o.uhdm; env "$@" dut.sv --single-unit --nobuiltin -o o.uhdm >/dev/null 2>&1; echo $?; }
  rl=$(run $L); mv o.uhdm l.uhdm 2>/dev/null; rf=$(run $F); mv o.uhdm f.uhdm 2>/dev/null
  mv=$(cmp -s l.uhdm f.uhdm && [ $rl = $rf ] && echo same || echo moved)
  ro=$(run R11V402_OFF=1 $F); off=$(cmp -s l.uhdm o.uhdm && [ $ro = $rl ] && echo VOFF=law || echo VOFF!=law)
  rest=""; if [ $mv = moved ]; then for s in GATETERM IMPTSOWNNAME; do ro=$(run R11V402_${s}_OFF=1 $F); cmp -s l.uhdm o.uhdm && [ $ro = $rl ] && rest="$rest $s"; done; fi
  echo "$rel | law rc=$rl | verified rc=$rf | $mv |${rest:- -} | $off"; done
