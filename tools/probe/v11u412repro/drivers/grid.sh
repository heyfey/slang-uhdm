#!/bin/bash
# grid.sh <casedir> [bi]: pristine, law, verified readings + switch checks (one line)
c=$1; bi=${2:-0}
law=$(head -1 $c/dut.sv | sed 's#^// § ##; s/ .*//'); sw=$(awk -v l=$law '$1==l{print $2}' /tmp/v11u412_drv/swmap.txt)
a=$(/tmp/v11u412_drv/vrun.sh $c $bi)
b=$(/tmp/v11u412_drv/v3.sh $c $bi)
rel=${c#/tmp/v11u412_cases/}; nbO="--nobuiltin"; [ "$bi" = 1 ] && nbO=""
o=/tmp/v11u412_out/$rel/s; rm -rf $o; mkdir -p $o
(cd $c && env $sw=1 timeout 300 /tmp/v11u412_bin/verified dut.sv --single-unit $nbO -o $o/ours.uhdm > $o/ours.log 2>&1; echo $? > $o/rc)
ms=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-8)
case $sw in R11V*) ref=l;; *) ref=p;; esac
mr=$(md5sum < /tmp/v11u412_out/$rel/$ref/ours.uhdm 2>/dev/null | cut -c1-8)
echo "$a $(echo "$b" | cut -d'|' -f2,5,6) | $sw==$( [ $ref = l ] && echo law || echo pristine ) $([ "$ms" = "$mr" ] && echo yes || echo NO)"
