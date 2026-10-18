#!/bin/bash
# grid.sh <casesroot> <pristine> <law> <tag> : one line per case (same columns as the implementer's grid402)
. /tmp/v11u402_env.sh
ROOT=$1; P=$2; L=$3; TAG=$4
SWS="ALIASELEM ANONSTRUCTEND ASSOCTD CLSCGPROP CLSEVENTARR GATEBITSEL GATEPRIM IMPTSCLONE MODCLOCKING NETKIND OOBMACRO TOPATTRSPAN UNINSTIFTD UNITOOB UNITOOBFN UTAGGEDSPAN UUNIONTD UUNIONVAR VIFELAB VIFTD VOIDMEM ${EXTRA_SWS}"
verdict(){ [ -f "$2" ] || { echo "NO_DB"; return; }
  if $UHDM_CMP $1 $2 >/dev/null 2>&1; then v=$(timeout 120 $STRICT $1 $2 2>&1 | tail -1); case "$v" in STRICT_EQUAL*) echo EQUAL;; *) echo "STRICT_NOTEQUAL:${v#STRICT_NOTEQUAL }";; esac; else echo NOT_EQUAL; fi; }
for c in $(cd $ROOT && find . -name dut.sv | sort); do
  d=$ROOT/${c%/dut.sv}; rel=${c#./}; rel=${rel%/dut.sv}
  w=/tmp/v11u402_gw_$TAG/$(echo $rel | tr / _); rm -rf $w; mkdir -p $w; cp $d/*.sv $w/
  h=$(cat $d/*.sv | md5sum | cut -c1-12); G=/tmp/v11u402_gold/$h
  if [ ! -f $G/slpp_all/surelog.uhdm ]; then rm -rf $G; mkdir -p $G; cp $d/*.sv $G/; (cd $G && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 >surelog.log 2>&1); fi
  g=$G/slpp_all/surelog.uhdm
  run(){ rm -f $w/o.uhdm; (cd $w && env "$@" dut.sv --single-unit --nobuiltin -o $w/o.uhdm >/dev/null 2>&1; echo $?); }
  rp=$(run $P); mv $w/o.uhdm $w/p.uhdm 2>/dev/null
  rl=$(run $L); mv $w/o.uhdm $w/l.uhdm 2>/dev/null
  vp=$(verdict $g $w/p.uhdm); vl=$(verdict $g $w/l.uhdm)
  rest=""; fires=""
  if ! cmp -s $w/p.uhdm $w/l.uhdm || [ $rp != $rl ]; then
    for s in $SWS; do ro=$(run R11U402_${s}_OFF=1 $L)
      if { cmp -s $w/p.uhdm $w/o.uhdm || { [ ! -f $w/p.uhdm ] && [ ! -f $w/o.uhdm ]; }; } && [ $ro = $rp ]; then rest="$rest $s"; fi
      if ! cmp -s $w/l.uhdm $w/o.uhdm || [ $ro != $rl ]; then fires="$fires $s"; fi
      rm -f $w/o.uhdm; done
    if cmp -s $w/p.uhdm $w/l.uhdm; then moved=rc-only; else moved=moved; fi
    if [ -z "$rest" ] && [ -n "$fires" ]; then
      ro=$(run $(for s in $fires; do echo R11U402_${s}_OFF=1; done) $L)
      if { cmp -s $w/p.uhdm $w/o.uhdm || { [ ! -f $w/p.uhdm ] && [ ! -f $w/o.uhdm ]; }; } && [ $ro = $rp ]; then rest="together:$(echo $fires | tr ' ' '+')"; else rest="UNRESTORED(fires:$fires)"; fi
      rm -f $w/o.uhdm
    fi
  else moved=same; fi
  ro=$(run R11U402_OFF=1 $L); if { cmp -s $w/p.uhdm $w/o.uhdm 2>/dev/null || { [ ! -f $w/p.uhdm ] && [ ! -f $w/o.uhdm ]; }; } && [ $ro = $rp ]; then off=OFF=pristine; else off=OFF!=pristine; fi; rm -f $w/o.uhdm
  echo "$rel | pristine rc=$rp $vp | law rc=$rl $vl | $moved |${rest:- -} | $off"
done
